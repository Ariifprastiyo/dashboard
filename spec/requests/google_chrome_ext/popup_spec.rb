require 'rails_helper'

RSpec.describe "GoogleChromeExt::Popups", type: :request do
  let(:user) { create(:user) }

  before do
    user.add_role :kol
    sign_in user
  end

  subject { get "/google_chrome_ext/popup" }

  include_examples "redirects to root path for non-super admin"

  describe "GET /index" do
    it "returns http success" do
      get "/google_chrome_ext/popup"
      expect(response).to have_http_status(:success)
    end
  end
end
