# encoding: utf-8

require 'rails_helper'


RSpec.describe ImportStatus, type: :model do
  let :status_registry do
    double(:status_registry)
  end

  let :status_data do
    {}
  end

  let :import_status do
    im = ImportStatus.new(id: '12345', status_registry: status_registry)
    im.valid?
    im
  end

  before do
    allow(status_registry).to receive(:get_all).and_return(status_data)
  end

  context 'when `id` exists' do
    let :status_data do
      {
        'status' => :working,
        'total' => '100',
        'at' => '30',
      }
    end

    it 'sets status' do
      expect(import_status.status).to eq(:working)
    end

    it 'calculates total progress' do
      expect(import_status.progress).to eq(30)
    end
  end

  context 'when `id` doesn\'t exist' do
    it 'is considered invalid' do
      expect(import_status).to be_invalid
    end

    it 'adds an error' do
      expect(import_status.errors[:import]).to eq(['id ("12345") doesn\'t exist'])
    end
  end
end
