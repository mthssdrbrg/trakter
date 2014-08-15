# encoding: utf-8

class ExportController < ApplicationController
  def new
    @export = Export.new
  end

  def create
    @export = Export.new(export_params)
    if @export.save
      csv = StringIO.new
      dump = MyEpisodes::Dump.new(client, csv)
      dump.execute
      send_data(csv.string, filename: export_filename, type: 'text/csv')
    else
      render :new
    end
  end

  def show
    head status: 501
  end

  def destroy
    head status: 501
  end

  private

  def export_params
    params.require(:export).permit(:username, :password)
  end

  # TODO: move everything below to model, or
  # at least somewhere else
  def client
    @client ||= MyEpisodes::Client.create(*export_params.values_at(:username, :password))
  end

  def export_filename
    %(#{date_ext}-#{@export.token}.csv)
  end

  def date_ext
    Time.now.strftime('%Y%m%d%H%M')
  end
end
