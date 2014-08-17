# encoding: utf-8

require 'rails_helper'


RSpec.describe Import, type: :model, vcr: {cassette_name: 'import'} do
  context 'for a valid Import' do
    before do
      allow(FileUtils).to receive(:copy_file)
    end

    it 'generates a token' do
      im = Import.create(attributes_for(:import))
      expect(im.token).to_not be_nil
    end

    it 'saves the CSV file to import locally' do
      im = Import.create(attributes_for(:import))
      expect(FileUtils).to have_received(:copy_file).at_least(:once)
    end

    it 'dispatches an import task' do
      im = Import.create(attributes_for(:import))
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
