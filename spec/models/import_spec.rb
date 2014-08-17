# encoding: utf-8

require 'rails_helper'


RSpec.describe Import, type: :model, vcr: {cassette_name: 'import'} do
  context 'for a valid Import' do
    let :im do
      build(:import, fileutils: fileutils)
    end

    let :fileutils do
      double(:fileutils, copy_file: nil)
    end

    before do
      im.save
    end

    it 'hashes the password' do
      expect(im.password).to eq('89e495e7941cf9e40e6980d14a16bf023ccd4c91')
    end

    it 'generates a token' do
      expect(im.token).to_not be_nil
    end

    it 'saves the CSV file to import locally' do
      expect(fileutils).to have_received(:copy_file)
    end

    it 'dispatches an import task' do
      expect(ImportWorker.jobs.size).to eq(1)
    end
  end

  context 'validations of an Import' do
    it 'validates presence of a CSV file' do
      im = build(:import, csv_file: nil)
      expect(im).to be_invalid
    end

    it 'validates credentials' do
      im = build(:import, username: 'blupp', api_key: 'FAULTY_API_KEY')
      expect(im).to be_invalid
    end
  end
end
