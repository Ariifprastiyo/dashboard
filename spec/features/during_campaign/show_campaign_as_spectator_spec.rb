require 'rails_helper'
include ActionView::Helpers::NumberHelper # we use number to currency

RSpec.feature "DuringCampaign::ShowCampaignAsSpectator", type: :feature do
  describe 'Show Campaign as Spectator' do
    include CompleteBasicSetup

    before do
      # create organization and assign to spectator
      organization = create(:organization)
      spectator = create(:user, organization: organization)
      spectator.add_role(:spectator)

      # assign campaign to organization
      @campaign.update(selected_media_plan: @media_plan, organization: organization)

      # assign campaign to organization
      sign_in spectator
    end

    it 'show the campaign' do
      require 'action_view' # Include the necessary module/library

      visit campaign_path(@campaign)

      # something spectator should see
      expect(page).to have_content(@campaign.name)
      expect(page).to have_content(@campaign.keyword)
      expect(page).to have_content(@campaign.start_at.strftime('%d %b %Y'))
      expect(page).to have_content(@campaign.end_at.strftime('%d %b %Y'))
      expect(page).to have_content(number_to_currency @campaign.budget_from_brand)
      expect(page).to have_content(number_to_currency @campaign.budget_remaining_sell_price)
      expect(page).to have_content(number_to_currency @campaign.budget_spent_sell_price)
      expect(page).to have_content('CRB Review')

      # check link
      expect(page).to have_link('CRB Review', href: media_comments_path(@campaign))
      expect(page).to have_link('Activity Report', href: campaign_activity_report_path(@campaign, { q: { social_media_account_size_in: ["0", "1", "2", "3"], created_at_gteq: @campaign.start_at.beginning_of_day, created_at_lteq: @campaign.end_at.end_of_day } }))

      # something spectator should not see
      expect(page).to_not have_content('Payment Requests')
      expect(page).to_not have_content('Performance Report')
      expect(page).to_not have_content('Import Publication')
      expect(page).to_not have_content('Show Publications')
      expect(page).to_not have_content('Show Timeline')
      expect(page).to_not have_content('Show Media Plan')
      expect(page).to_not have_content('Recalculate CRB')
      # expect(page).to_not have_content(number_to_currency @campaign.budget)
      # expect(page).to_not have_content(number_to_currency @campaign.budget_remaining)
      # expect(page).to_not have_content(number_to_currency @campaign.budget_spent)
    end
  end
end
