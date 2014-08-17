# encoding: utf-8

class ImportController < ApplicationController
  def new
    @import = Import.new
  end

  def create
    @import = Import.new(import_params)
    respond_to do |format|
      if @import.valid?
        format.html { redirect_to url_for(import_path(@import.job_id)) }
        format.json { render json: @import, status: :created }
      else
        format.html { render :new }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @import = ImportStatus.new(show_params)
    if @import.valid?
      respond_to do |format|
        format.html
        format.json { render json: @import }
      end
    else
      respond_to do |format|
        format.html { redirect_to new_import_path }
        format.json { render json: @import.errors }
      end
    end
  end

  def destroy
    head status: 501
  end

  private

  def import_params
    params.require(:import).permit(:api_key, :username, :password, :csv_file)
  end

  def show_params
    params.permit(:id)
  end
end
