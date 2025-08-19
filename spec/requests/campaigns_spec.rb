require 'rails_helper'

RSpec.describe "/campaigns", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Campaign. As you add validations to Campaign, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      "name" => "MyString",
      "brand_id" => campaign.brand_id,
      "description" => nil,
      "status" => "active",
      "start_at" => 'Mon, 26 Dec 2022 15:29:58.000000000 UTC +00:00',
      "end_at" => "Mon, 26 Dec 2022 16:29:58.000000000 UTC +00:00",
      "budget" => 100000,
      "kpi_reach" => 1.5,
      "kpi_impression" => 1.5,
      "kpi_engagement_rate" => 1.5,
      "kpi_cpv" => 100,
      "kpi_cpr" => 20,
      "kpi_number_of_social_media_accounts" => 1,
      "platform" => 'instagram',
      "invitation_expired_at" => 'Mon, 31 Dec 2022 15:29:58.000000000 UTC +00:00'
  }}

  let(:invalid_attributes) {
    {
      name: nil
    }
  }

  let!(:organization) { create(:organization) }
  let!(:admin) { create(:admin, organization: organization) }
  let!(:brand) { create(:brand, organization: organization) }
  let!(:campaign) { create(:campaign, organization: organization, brand: brand) }


  let!(:other_organization) { create(:organization) }
  let!(:other_admin) { create(:admin, organization: other_organization) }
  let!(:other_brand) { create(:brand, organization: other_organization) }
  let!(:other_campaign) { create(:campaign, organization: other_organization) }

  let!(:super_admin) { create(:super_admin) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "renders a successful response" do
      get campaigns_url
      expect(response).to be_successful
    end

    it "shows only the campaigns from the user organization" do
      get campaigns_url
      expect(response.body).to include(campaign.name)
      expect(response.body).not_to include(other_campaign.name)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get campaign_url(campaign)
      expect(response).to be_successful
    end

    it "returns a 404 when the campaign is from another organization" do
      get campaign_url(other_campaign)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_campaign_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_campaign_url(campaign)
      expect(response).to be_successful
    end

    it "returns a 404 when the campaign is from another organization" do
      get edit_campaign_url(other_campaign)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /timeline" do
    before {  allow_any_instance_of(Campaign).to receive(:selected_media_plan).and_return(create(:media_plan)) }

    it "renders successful response" do
      get timeline_campaign_url(campaign)
      expect(response).to be_successful
    end

    it "returns a 404 when the campaign is from another organization" do
      get timeline_campaign_url(other_campaign)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Campaign for that organization" do
        expect {
          post campaigns_url, params: { campaign: valid_attributes }
        }.to change(Campaign, :count).by(1)

        expect(Campaign.last.organization).to eq(organization)
      end

      it "redirects to the created campaign" do
        post campaigns_url, params: { campaign: valid_attributes }
        expect(response).to redirect_to(campaign_url(Campaign.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Campaign" do
        expect {
          post campaigns_url, params: { campaign: invalid_attributes }
        }.to change(Campaign, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post campaigns_url, params: { campaign: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new Campaign for another organization" do
        attributes = valid_attributes.merge(organization_id: other_organization.id)

        post campaigns_url, params: { campaign: attributes }

        expect(Campaign.last.organization_id).not_to eq(other_organization.id)
        expect(Campaign.last.organization_id).to eq(organization.id)
      end

      xit "does not create a new Campaign with other organization\'s brand" do
        attributes = valid_attributes.merge(brand_id: other_brand.id)
        expect {
          post campaigns_url, params: { campaign: attributes }
        }.to change(Campaign, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: "New Name" }
      }

      it "updates the requested campaign" do
        patch campaign_url(campaign), params: { campaign: new_attributes }
        campaign.reload

        expect(campaign.name).to eq('New Name')
      end

      it "redirects to the campaign" do
        patch campaign_url(campaign), params: { campaign: new_attributes }
        campaign.reload
        expect(response).to redirect_to(campaign_url(campaign))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        patch campaign_url(campaign), params: { campaign: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the requested campaign from another organization" do
        patch campaign_url(other_campaign), params: { campaign: { name: "New Name" } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested campaign" do
      expect {
        delete campaign_url(campaign)
      }.to change(Campaign.kept, :count).by(-1)
    end

    it "does not destroy the requested campaign from another organization" do
      delete campaign_url(other_campaign)
      expect(response).to have_http_status(:not_found)
    end

    it "redirects to the campaigns list" do
      delete campaign_url(campaign)
      expect(response).to redirect_to(campaigns_url)
    end
  end
end
