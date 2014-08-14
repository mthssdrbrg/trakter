# encoding: utf-8

module Traktim
  class CsvImportJob
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    sidekiq_options retry: false

    require 'csv'
    require 'traktr'

    def initialize
      @processed = 0
      @show = nil
    end

    def perform(path, api_key, username, password)
      @client = Traktr::Client.new(api_key, username, password)
      total_count = calculate_total(path)
      total(total_count)
      csv = CSV.new(File.new(path, 'r'), headers: true, col_sep: ';', quote_char: '|').to_a
      while csv.any? do
        item = csv.shift
        items = csv.take_while { |r| r['show'] == item['show'] && r['season'] == item['season'] }
        import(item, items)
        mark_as_processed(items.size + 1)
        csv = csv.drop(items.size)
      end
    end

    private

    def import(item, items)
      name, number = item.values_at('show', 'number')
      if (show = fetch_show(name))
        season_nr = number.split('x', 2).first.to_i
        if (season = fetch_season(show, season_nr)) && season.any?
          episodes = create_episodes(season, item, *items)
          mark_as_seen(show, *episodes) if episodes.any?
        else
          logger.warn 'Could not find info for season %s of %s' % [season_nr.inspect, show.title.inspect]
        end
      else
        logger.warn 'Could not find info for show %s' % name.inspect
      end
    end

    def create_episodes(season, *items)
      watched = items.reject { |item| item['watched'] == 'false' }
      watched = watched.map do |item|
        s, ep = item['number'].split('x').map(&:to_i)
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
      f = File.new(path, 'r')
      f.each_line.reduce(-1) { |s, _| s += 1 }
    ensure
      f.close if f
    end
  end
end
