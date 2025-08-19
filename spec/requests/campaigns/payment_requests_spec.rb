require 'rails_helper'

RSpec.describe "Campaigns::PaymentRequests", type: :request do
  let(:admin) { create(:admin) }
  let(:campaign) { create(:campaign) }

  before do
    admin.add_role :super_admin
    sign_in admin
  end

  describe "GET /index" do
    it "returns http success" do
      get "/campaigns/#{campaign.id}/payment_requests"
      expect(response).to have_http_status(:success)
    end
  end
end
