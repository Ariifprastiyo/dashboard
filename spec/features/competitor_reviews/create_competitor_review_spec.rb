require 'rails_helper'

RSpec.feature "CompetitorReviews::CreateCompetitorReview", type: :feature, js: false do
  let!(:super_admin) { create(:super_admin) }
  let!(:organization) { create(:organization, name: 'My Organization') }
  let!(:brand) { create(:brand, name: 'My Brand') }
  let!(:campaign) { create(:campaign, organization: organization, name: 'My Campaign') }

  before do
    sign_in super_admin
    visit competitor_reviews_path
  end

  scenario 'super admin creates a new competitor review' do
    click_on 'New Competitor Review'

    fill_in 'Title', with: 'Test Competitor Review'
    # Select organization
    find('#select2-competitor_review_organization_id-container').click
    find('li.select2-results__option', text: organization.name).click

    # Select campaign
    find('span.select2-selection--multiple').click
    find('li.select2-results__option', text: campaign.name).click

    click_on 'Buat Competitor review'

    expect(page).to have_content('Competitor review was successfully created.')
    expect(page).to have_content('Test Competitor Review')
    expect(page).to have_content(campaign.name)
  end

  scenario 'super admin tries to create an invalid competitor review' do
    click_on 'New Competitor Review'

    # Leave all fields blank
    click_on 'Buat Competitor review'

    expect(page).not_to have_content('Competitor review was successfully created')
  end

  scenario 'super admin creates a competitor review with multiple campaigns' do
    another_campaign = create(:campaign, organization: organization)

    click_on 'New Competitor Review'

    fill_in 'Title', with: 'Test Competitor Review'
    # Select organization
    find('#select2-competitor_review_organization_id-container').click
    find('li.select2-results__option', text: organization.name).click

    # Select campaign
    find('span.select2-selection--multiple').click
    find('li.select2-results__option', text: campaign.name).click

    find('span.select2-selection--multiple').click
    find('li.select2-results__option', text: another_campaign.name).click

    click_on 'Buat Competitor review'

    expect(page).to have_content('Competitor review was successfully created.')
    expect(page).to have_content('Test Competitor Review')
    expect(page).to have_content(campaign.name)
    expect(page).to have_content(another_campaign.name)
  end
end
