# encoding: utf-8

require 'stringio'
require 'my_episodes'


class MyEpisodesController < ApplicationController
  def export
    if username.present? && password.present?
      csv = StringIO.new
      dump = MyEpisodes::Dump.new(client, csv)
      dump.execute
      send_data(csv.string, filename: export_filename, type: 'text/csv', disposition: 'attachment')
    end
  end

  private

  def client
    @client ||= MyEpisodes::Client.create(username, password)
  end

  def username
    params[:username]
  end

  def password
    params[:password]
  end

  def export_filename
    %(myepisodes-#{username}-#{date_ext}.csv)
  end

  def date_ext
    Time.now.strftime('%Y%m%d%H%M')
  end
end
