# encoding: utf-8

require 'rails_helper'


RSpec.describe ImportController, type: :controller, vcr: {cassette_name: 'import'} do
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
    before do
      allow(FileUtils).to receive(:copy_file).and_return(true)
    end

    context 'with valid Trakt.tv credentials' do
      it 'redirects to GET #show for the created import' do
        post :create, {import: attributes_for(:import)}
        expect(response).to redirect_to(import_path(assigns(:import).job_id))
      end
    end

    context 'with invalid Trakt.tv credentials' do
      it 'renders the `new` template' do
        post :create, {import: attributes_for(:import).merge(api_key: 'FAULTY_API_KEY', username: 'blupp')}
        expect(response).to render_template('new')
      end
    end
  end

  describe 'GET #show' do
    context 'and an `id` that exists' do
      pending
    end

    context 'and an `id` that doesn\'t exist' do
      pending
    end
  end

  describe 'DELETE #destroy' do
    pending
  end
end
