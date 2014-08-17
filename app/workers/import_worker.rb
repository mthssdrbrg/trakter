# encoding: utf-8

class ImportWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  require 'csv'
  require 'traktr'

  def initialize
    @processed = 0
    @show = nil
  end

  def perform(token, api_key, username, password)
    @client = Traktr::Client.new(api_key, username, password, true)
    csv_filepath = Import.path_for_token(token)
    total_count = calculate_total(csv_filepath)
    total(total_count)
    csv = CSV.new(File.new(csv_filepath, 'r'), headers: true, col_sep: ';', quote_char: '|').to_a
    while csv.any? do
      item = csv.shift
      items = csv.take_while { |r| r['show'] == item['show'] && r['season'] == item['season'] }
      import(item, items)
      mark_as_processed(items.size + 1)
      csv = csv.drop(items.size)
    end
  end

  private

  def extract_season_episode_nr(s)
    if (m = s.match(/(\d+)x(\d+)/i))
      m.captures
    elsif (m = s.match(/s(\d+)e(\d+)/i))
      m.captures
    else
      nil
    end
  end

  def import(item, items)
    name, number = item.values_at('show', 'number')
    if (show = fetch_show(name))
      if (season_nr = extract_season_episode_nr(number))
        season_nr = season_nr.first.to_i
        if (season = fetch_season(show, season_nr)) && season.any?
          episodes = create_episodes(season, item, *items)
          mark_as_seen(show, *episodes) if episodes.any?
        else
          logger.warn 'Could not find info for season "%s" of "%s"' % [season_nr, show.title]
        end
      else
        logger.warn 'Could not extract season & episode nr from "%s"' % [number]
      end
    else
      logger.warn 'Could not find info for show %s' % name.inspect
    end
  end

  def create_episodes(season, *items)
    watched = items.reject { |item| item['watched'] == 'false' }
    watched = watched.map do |item|
      s, ep = extract_season_episode_nr(item['number']).map(&:to_i)
      Mash.new(season: s, episode: ep)
    end
    watched = watched.reject { |item| already_watched?(season, item) }
    watched
  end

  def mark_as_processed(count)
    @processed += count
    at(@processed)
  end

  def mark_as_seen(show, *episodes)
    logger.info 'Marking %d episodes as seen for %s' % [episodes.size, show.inspect]
    @client.show.episode.seen(show, episodes)
  end

  def fetch_show(name)
    if @show.nil? || @show.title.downcase != name.downcase
      logger.debug 'Fetching info for %s' % name
      @show = @client.search.shows(CGI.escape(name), 1).first
    end
    @show
  end

  def fetch_season(show, nr)
    @client.show.season(show.tvdb_id.to_s, nr.to_s)
  end

  def already_watched?(season, episode)
    s = season.find { |se| se.number == episode.episode || se.episode == episode.episode }
    if s && !s.watched.nil?
      s.watched
    else
      logger.debug 'Could not find episode %s in season %s, ignoring' % [episode.episode, episode.season].map(&:inspect)
      true
    end
  end

  def calculate_total(path)
    File.open(path, 'r') do |f|
      f.each_line.reduce(-1) { |s, _| s += 1 }
    end
  end
end
