require 'rails_helper'

RSpec.describe "PublicationHistories", type: :request do
  include CompleteBasicSetup

  before do
    admin = create(:admin)
    sign_in admin
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get "/publication_histories/new?social_media_publication_id=#{@pub.id}"

      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    it 'renders a successful response' do
      params = FactoryBot.attributes_for(:publication_history, social_media_publication_id: @pub.id)

      initial_pub_history_count = PublicationHistory.count

      post "/publication_histories", params: { publication_history: params }

      # expect to be redirected
      expect(response).to be_redirect
      expect(PublicationHistory.count).to eq(initial_pub_history_count + 1)
    end

    it 'renders new if params are invalid' do
      post "/publication_histories", params: { publication_history: { social_media_publication_id: nil } }

      # excpect render new
      expect(response).not_to be_successful
    end
  end

  describe 'GET /edit' do
    it 'renders a successful response' do
      get "/publication_histories/#{@ph.id}/edit"

      expect(response).to be_successful
    end
  end

  describe 'PUT /update' do
    it 'renders a successful response' do
      params = FactoryBot.attributes_for(:publication_history, social_media_publication_id: @pub.id)

      put "/publication_histories/#{@ph.id}", params: { publication_history: params }

      expect(response).to be_redirect
    end

    it 'renders edit if params are invalid' do
      put "/publication_histories/#{@ph.id}", params: { publication_history: { social_media_publication_id: nil } }

      expect(response).not_to be_successful
    end
  end
end
