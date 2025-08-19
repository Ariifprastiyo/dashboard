require 'rails_helper'

RSpec.describe "MediaPlans", type: :request do
  let(:valid_attributes) {
    build(:media_plan).attributes
  }

  let(:invalid_attributes) {
    valid_attributes.merge(name: nil)
  }

  let!(:organization) { create(:organization) }
  let!(:user) { create(:admin, organization: organization) }
  let!(:brand) { create(:brand, organization: organization) }
  let!(:campaign) { create(:campaign, organization: organization, brand: brand) }
  let!(:media_plan) { create(:media_plan, campaign: campaign) }

  let!(:other_organization) { create(:organization) }
  let!(:other_user) { create(:admin, organization: other_organization) }
  let!(:other_brand) { create(:brand, organization: other_organization) }
  let!(:other_campaign) { create(:campaign, organization: other_organization, brand: other_brand) }
  let!(:other_media_plan) { create(:media_plan, campaign: other_campaign) }

  let!(:super_admin) { create(:super_admin) }

  before do
    sign_in user
  end

  describe "GET /show" do
    it "renders a successful response" do
      get media_plan_url(media_plan)
      expect(response).to be_successful
    end

    it "returns a 404 when the media plan is from another organization" do
      get media_plan_url(other_media_plan)
      expect(response).to have_http_status(:not_found)
    end

    it "shows all media plans to super admins" do
      sign_out user
      sign_in super_admin

      get media_plan_url(other_media_plan)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_media_plan_url(media_plan)
      expect(response).to be_successful
    end

    it "returns a 404 when the Media Plan is from another organization" do
      get edit_media_plan_url(other_media_plan)
      expect(response).to have_http_status(:not_found)
    end

    it "renders edit page for super admin" do
      sign_out user
      sign_in super_admin

      get edit_media_plan_url(other_media_plan)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Media Plan" do
        expect {
          post media_plans_url, params: { media_plan: valid_attributes }
        }.to change(MediaPlan, :count).by(1)
      end

      it "redirects to the created media plan" do
        post media_plans_url, params: { media_plan: valid_attributes }
        expect(response).to redirect_to(new_media_plan_scope_of_work_url(MediaPlan.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Media Plan" do
        expect {
          post media_plans_url, params: { media_plan: invalid_attributes, campaign_id: campaign.id }
        }.to change(MediaPlan, :count).by(0)
      end

      it "raises a 404 when the campaign is from another organization" do
        post media_plans_url, params: { media_plan: invalid_attributes, campaign_id: other_campaign.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: 'New MediaPlan' }
      }

      it "updates the requested media_plan" do
        patch media_plan_url(media_plan), params: { media_plan: new_attributes }
        media_plan.reload

        expect(media_plan.name).to eq('New MediaPlan')
      end

      it "redirects to the media_plan" do
        patch media_plan_url(media_plan), params: { media_plan: new_attributes }
        media_plan.reload

        expect(response).to redirect_to(media_plan_url(media_plan))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        patch media_plan_url(media_plan), params: { media_plan: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a 404 when the media_plan is from another organization" do
        patch media_plan_url(other_media_plan), params: { media_plan: { name: 'New MediaPlan' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested media_plan" do
      expect {
        delete media_plan_url(media_plan)
      }.to change(MediaPlan, :count).by(-1)
    end

    it "redirects to the media_plans list" do
      delete media_plan_url(media_plan)
      expect(response).to redirect_to(campaign_url(media_plan.campaign))
    end

    it "returns a 404 when the media_plan is from another organization" do
      delete media_plan_url(other_media_plan)
      expect(response).to have_http_status(:not_found)
    end
  end
end
