# encoding: utf-8

require 'rails_helper'


RSpec.describe Export, :type => :model do
  it 'generates a token from `username` and `created_at`' do
    ex = create(:export, created_at: Time.utc(2014, 8, 14, 1))
    expect(ex.token).to eq('36b975cbe095e9ee837073d7c5619c31')
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

  context 'an Export that' do
    context 'is missing username' do
      it 'is invalid' do
        ex = build(:export, username: nil)
        expect(ex).to be_invalid
      end
    end

    context 'is missing password' do
      it 'is invalid' do
        ex = build(:export, password: nil)
        expect(ex).to be_invalid
      end
    end
  end
end
