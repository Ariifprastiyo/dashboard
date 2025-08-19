require 'rails_helper'

RSpec.describe "ActivityReports", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
  let(:campaign) { create(:campaign) }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
  let!(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 10_000_000, posted_at: '2023-01-01') }
  let!(:social_media_publication) { create(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }
  let!(:publication_history) { create(:publication_history, campaign: campaign, social_media_publication: social_media_publication, social_media_account: account, platform: :instagram, reach: 100, likes_count: 100, share_count: 100, comments_count: 100, engagement_rate: 100, created_at: '2023-01-01', social_media_account_size: :mega) }

  before do
    social_media_publication.sync_daily_update
    user.add_role :admin
    user.add_role :super_admin
    sign_in user
  end

  let(:campaign_activity_report_request) do
    campaign_activity_report_path(
      campaign, {
        q: {
          social_media_account_size_in: ["0", "1", "2", "3"],
          created_at_gteq: "2023-01-01",
          created_at_lteq: "2023-12-31"
        }
      }
    )
  end



  describe "GET /show" do
    it "renders a successful response" do
      get campaign_activity_report_request
      expect(response).to be_successful
    end

    it "displays the correct title table name 'Activity Report" do
      get campaign_activity_report_request
      parsed_body = Nokogiri::HTML(response.body)
      title = parsed_body.css('h5.card-title.m-0.p-0').first.text
      expect(title).to eq('Activity Report')
    end

    it "displays the correct title table name 'Publication Histories" do
      get campaign_activity_report_request
      parsed_body = Nokogiri::HTML(response.body)
      title = parsed_body.css('h5.card-title.m-0.p-0').last.text
      expect(title).to eq('Publication Histories')
    end

    it "get the expected column names on table 'Publication Histories'" do
      get campaign_activity_report_request
      parsed_body = Nokogiri::HTML(response.body)
      column_names = ['#', 'Publication ID', 'URL', 'Additional info', 'Account', 'Size', 'Platform', 'Views', 'Likes', 'Share', 'Comment', 'Total Engagement', 'ER', 'Price', 'Created At', 'Posted At']

      column_names.each do |column_name|
        column = parsed_body.css('thead th').find { |th| th.text == column_name }
        expect(column).not_to be_nil, "Expected to find column '#{column_name}', but did not."
      end
    end

    it 'export correct csv file' do
      get campaign_activity_report_path(
        campaign, {
          q: {
            social_media_account_size_in: ["0", "1", "2", "3"],
            created_at_gteq: "2023-01-01",
          created_at_lteq: "2023-12-31"
          },
          format: :csv
        }
      )

      expect(response.headers['Content-Type']).to eq('text/csv')
      # evaluate the CSV content header row
      expect(response.body).to include('ID,Publication ID,URL,Additional info,Account,Size,Platform,Views,Likes,Share,Comment,Total Engagement,ER,CRB%,CRB count,CPV,CPR,CPE,Price,Created At,Posted At')
      expect(response.body).to include("#{publication_history.id},#{social_media_publication.id},https://www.instagram.com/p/Cm6gLZrI21p,,fadiljaidi,mega,instagram,100,100,100,100,300,\"100,00%\",\"0,00%\",0,1,1,15,10000000,\"Sunday, January 01, 2023\",\"Monday, January 02, 2023\"")
    end

    context 'when user is spectator' do
      # Spectator need to be in an organization
      let(:organization) { create(:organization) }
      let(:spectator) { create(:spectator, organization: organization) }

      before do
        spectator.remove_role :super_admin
        spectator.remove_role :admin
        spectator.add_role :spectator
        campaign.update(organization: organization)

        sign_in spectator
      end

      it 'should be successful' do
        get campaign_activity_report_request

        expect(response.body).to_not include('Sell Price')
        expect(response).to be_successful
      end
    end
  end
end
