require 'rails_helper'

RSpec.describe "Accounts", type: :request do
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/account/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /account" do
    it "returns http success" do
      put "/account", params: { user: { name: "New Name" } }
      expect(response).to have_http_status(:found)
    end
  end
end
