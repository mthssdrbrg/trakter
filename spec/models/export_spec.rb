# encoding: utf-8

require 'rails_helper'


RSpec.describe Export, type: :model do
  context 'for a valid Export', vcr: {cassette_name: 'valid-credentials', allow_playback_repeats: true} do
    it 'generates a token from `username` and `created_at`' do
      ex = create(:export, created_at: Time.utc(2014, 8, 14, 1))
      expect(ex.token).to eq('215d3c7af43c7e7b78458573d9f116da')
    end

    it 'generates a new token for each created Export' do
      now = Time.utc(2014, 8, 14, 2)
      ex1 = create(:export, created_at: now)
      ex2 = create(:export, created_at: now - 1)
      expect(ex1.token).to_not eq(ex2.token)
    end

    it 'sets `created_at`' do
      ex = create(:export, created_at: nil)
      expect(ex.created_at).to_not be_nil
    end
  end

  context 'validations of an Export', vcr: {cassette_name: 'invalid-credentials'} do
    it 'validates presence of `username`' do
      ex = build(:export, username: '')
      expect(ex).to be_invalid
    end

    it 'validates presence of `password`' do
      ex = build(:export, password: '')
      expect(ex).to be_invalid
    end

    it 'validates credentials' do
      ex = build(:export, username: 'demo', password: 'this is wrong')
      expect(ex).to be_invalid
      expect(ex.errors[:credentials]).to include('invalid username and / or password')
    end
  end
end
