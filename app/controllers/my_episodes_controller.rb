# encoding: utf-8

require 'my_episodes'


class MyEpisodesController < ApplicationController
  def export
    if username.present? && password.present?
      csv = StringIO.new
      dump = MyEpisodes::Dump.new(client, csv)
      dump.execute
      send_data(csv.string, filename: export_filename, type: 'text/csv')
    else
      render nothing: true
    end
  end

  private

  def client
    @client ||= MyEpisodes::Client.create(username, password)
  end

  def export_filename
    %(myepisodes-#{username}-#{date_ext}.csv)
  end

  def username
    @username ||= params[:username]
  end

  def password
    params[:password]
  end

  def date_ext
    Time.now.strftime('%Y%m%d%H%M')
  end
end
