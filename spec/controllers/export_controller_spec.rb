# encoding: utf-8

require 'rails_helper'


RSpec.describe ExportController, type: :controller do
  describe 'GET #new' do
    it 'responds successfully with an HTTP 200 status code' do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the `new` template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    context 'with valid MyEpisodes credentials', vcr: {cassette_name: 'export'} do
      let :credentials do
        {username: 'demo', password: 'demo'}
      end

      it 'responds successfully with an HTTP 200 status code' do
        post :create, export: credentials
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it 'sets `csv` content type' do
        post :create, export: credentials
        expect(response.content_type).to eq('text/csv')
      end

      it 'renders exported CSV' do
        post :create, export: credentials
        output = response.body.split("\n")
        expect(output).to_not be_empty
        expect(output.size).to be > 1
      end
    end

    context 'with invalid MyEpisodes credentials' do
      pending
    end
  end

  describe 'GET #show' do
    it 'renders "Not implemented" status' do
      get :show, id: 'TOKEN'
      expect(response).to have_http_status(501)
    end

    context 'with a valid token' do
      it 'returns http success'
    end

    context 'with an unknown token' do
      it 'redirects to #new'
    end
  end

  describe 'DELETE #destroy' do
    it 'renders "Not implemented" status' do
      delete :destroy, id: 'TOKEN'
      expect(response).to have_http_status(501)
    end

    context 'with a token that hasn\'t expired' do
      it 'deletes the referred export'
    end

    context 'with a token that doesn\'t exist' do
      it 'returns 404'
    end
  end
end
