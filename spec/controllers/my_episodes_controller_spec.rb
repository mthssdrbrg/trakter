# encoding: utf-8

require 'rails_helper'


RSpec.describe MyEpisodesController, type: :controller do
  describe 'GET #index' do
    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the `index` template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'POST #export', vcr: {cassette_name: 'export'} do
    context 'with MyEpisodes credentials' do
      let :credentials do
        {username: 'demo', password: 'demo'}
      end

      it 'responds successfully with an HTTP 200 status code' do
        post :export, credentials
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets `csv` content type' do
        post :export, credentials
        expect(response.content_type).to eq('text/csv')
      end

      it 'renders exported CSV' do
        post :export, credentials
        output = response.body.split("\n")
        expect(output).to_not be_empty
        expect(output.size).to be > 1
      end
    end

    context 'without MyEpisodes credentials' do
      pending
    end
  end
end
