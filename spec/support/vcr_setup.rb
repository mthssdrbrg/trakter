# encoding: utf-8

require 'vcr'


VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    preserve_exact_body_bytes: false,
    decode_compressed_response: true,
    allow_playback_repeats: true,
    match_requests_on: [:method, :uri, :body]
  }
end
