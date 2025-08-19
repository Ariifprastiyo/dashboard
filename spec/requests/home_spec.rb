require 'rails_helper'

RSpec.describe "Homes", type: :request do
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get "/home/index"
      expect(response).to have_http_status(:success)
    end
  end
end
