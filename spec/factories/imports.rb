# encoding: utf-8

FactoryGirl.define do
  factory :import do
    api_key 'DEMO_API_KEY'
    username 'demo'
    password 'demo'
    csv_file { Rack::Test::UploadedFile.new('spec/fixtures/csv/demo-import.csv', 'text/csv') }
  end
end
