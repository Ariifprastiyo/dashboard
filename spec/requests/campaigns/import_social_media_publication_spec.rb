require 'rails_helper'

RSpec.describe "Campaigns::ImportSocialMediaPublications", type: :request do
  let(:user) { create(:admin) }
  let(:campaign) { create(:campaign) }
  let(:media_plan) { create(:media_plan, :empty, campaign: campaign) }
  let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
  let(:scope_of_work_items) { create_list(:scope_of_work_item, 2, scope_of_work: scope_of_work, sell_price: 1000) }

  before do
    user.add_role :admin
    user.add_role :super_admin
    campaign.update(selected_media_plan: media_plan)
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get "/campaigns/#{campaign.id}/import_social_media_publications"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get "/campaigns/#{campaign.id}/import_social_media_publications/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #download_template" do
    it "generates template with correct name file " do
      get download_template_campaign_import_social_media_publications_path(campaign.id)

      expected_filename = "#{campaign.name.parameterize.underscore}_template.xlsx"

      expect(response.headers["Content-Disposition"]).to include(expected_filename)
    end

    it "generates template with correct content" do
      file_path = Rails.root.join('spec', 'fixtures', 'files', 'campaign_1_template.xlsx')
      # Use Roo to read the content of the Excel file
      file_content = Roo::Excelx.new(file_path)

      # Check the header
      expect(file_content.cell(1, 1)).to eq("no")
      expect(file_content.cell(1, 2)).to eq("social_media_account")
      expect(file_content.cell(1, 3)).to eq("platform")
      expect(file_content.cell(1, 4)).to eq("sow_item_name")
      expect(file_content.cell(1, 5)).to eq("sow_item_id")
      expect(file_content.cell(1, 6)).to eq("url")

      # Check the content
      expect(file_content.cell(2, 1)).to eq(1)
      expect(file_content.cell(2, 2)).to eq(scope_of_work_items[0].social_media_account.username)
      expect(file_content.cell(2, 3)).to eq(scope_of_work_items[0].social_media_account.platform)
      expect(file_content.cell(2, 4)).to eq(scope_of_work_items[0].name)
    end
  end

  describe 'POST /create' do
  end

  describe 'DESTROY /destroy' do
  end
end
