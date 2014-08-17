# encoding: utf-8

require 'rails_helper'


RSpec.describe ImportController, type: :controller, vcr: {cassette_name: 'import'} do
  describe 'GET #new' do
    before do
      get :new
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'renders the `new` template' do
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
    context 'with an `id` that exists' do
      before do
        allow(Sidekiq::Status).to receive(:get_all).and_return({
          'status' => :working,
          'total' => '100',
          'at' => '30',
        })
      end

      context 'for `html` format' do
        before do
          get :show, id: '12345'
        end

        it 'renders `show` template' do
          expect(response).to render_template('show')
        end
      end

      context 'for `json` format' do
        before do
          get :show, id: '12345', format: :json
        end

        it 'renders status as JSON' do
          expect { JSON.parse(response.body) }.to_not raise_error
        end
      end
    end

    context 'and an `id` that doesn\'t exist' do
      before do
        allow(Sidekiq::Status).to receive(:get_all).and_return({})
      end

      context 'for `html` format' do
        before do
          get :show, id: '12345'
        end

        it 'redirects to creating a new import' do
          expect(response).to redirect_to(new_import_path)
        end

        it 'displays a flash message'
      end

      context 'for `json` format' do
        before do
          get :show, id: '12345', format: :json
        end

        it 'responds with a 404 status code' do
          expect(response).to have_http_status(404)
        end

        it 'renders an error' do
          body = JSON.parse(response.body)
          expect(body).to have_key('import')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, id: '12345'
    end

    it 'renders "Not implemented" status' do
      expect(response).to have_http_status(501)
    end
  end
end
