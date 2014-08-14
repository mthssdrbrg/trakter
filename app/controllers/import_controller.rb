# encoding: utf-8

require 'traktim'


class ImportController < ApplicationController
  def import
    username = params[:username]
    password = params[:password]
    api_key = params[:api_key]
    file = params[:import_file]
    uploaded_filename = "public/uploads/#{file.original_filename}"
    uploaded_file = File.new(uploaded_filename, 'w+')
    file.tempfile.each_line do |line|
      uploaded_file.puts(line.force_encoding('UTF-8'))
    end
    file.close
    uploaded_file.close
    @job_id = Traktim::CsvImportJob.perform_async(uploaded_filename, api_key, username, password)
    @job_data = Sidekiq::Status.get_all(@job_id)
    respond_to do |format|
      format.js
      format.json { render(json: {job_id: job_id}) }
    end
  end

  def status
    if job_id.present? && job_data.present?
      respond_to do |format|
        format.js
        format.json { render json: job_data }
      end
    end
  end

  private

  def job_id
    @job_id ||= params[:job_id]
  end

  def job_data
    @job_data ||= begin
      data = Sidekiq::Status.get_all(job_id)
      if data && data.any?
        data
      end
    end
  end
end
