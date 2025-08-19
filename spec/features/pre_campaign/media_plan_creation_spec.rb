require 'rails_helper'

RSpec.feature "PreCampaign::MediaPlanCreations", type: :feature do
  # make sure we pass the logic for taking the post max 3 months old
  Timecop.freeze(Time.parse("2023-03-10 14:02:08"))

  after(:all) do
    Timecop.return
  end

  let(:user) { create(:super_admin) }
  let!(:brand) { create(:brand) }
  let(:kpi_reach) { 40_000 }
  let(:kpi_engagement_rate) { 1 }
  let(:kpi_cpv) { 100 }
  let(:kpi_cpr) { 100 }
  let(:kpi_impression) { 100_000 }
  let(:kpi_number_of_social_media_accounts) { 3 }
  let(:budget) { 200_000 }
  let(:budget_from_brand) { 300_000 }

  let!(:tasyakamila) { create(:social_media_account, :instagram, username: 'tasyakamila') }
  let!(:fadiljaidi) { create(:social_media_account, :instagram, username: 'fadiljaidi') }

  before do
    user.add_role(:admin)
    sign_in user
    visit campaigns_path
  end

  scenario 'user creates a media plan, add kol, see the metric changes' do
    create_new_campaign

    # Create Media Plan
    click_on 'New Media Plan'

    fill_in 'Name', with: 'Media Plan 1'
    fill_in 'Story Qty', with: '1'
    fill_in 'Feed photo Qty', with: '1'
    fill_in 'Feed video Qty', with: '1'

    click_on 'next'

    expect(page).to have_content('Media Plan 1')

    # Add KOL
    faidiljaidi_add_button = page.all('.bi-plus-lg').first
    faidiljaidi_add_button.click

    tasya_add_button = page.all('.bi-plus-lg').first
    tasya_add_button.click

    # See the metric changes
    kpi_kol = page.find(:xpath, '/html/body/main/section/div[1]/div[1]/div/div/div/div[2]')
    kpi_impression = page.find(:xpath, '/html/body/main/section/div[1]/div[2]/div/div')
    kpi_er = page.find(:xpath, '//*[@id="kpi-card-engagement-rate"]')
    kpi_reach = page.find(:xpath, '/html/body/main/section/div[1]/div[4]/div/div/div/div[2]')
    kpi_budget = page.find(:xpath, '/html/body/main/section/div[1]/div[6]/div')
    kpi_costs = page.find(:xpath, '//*[@id="kpi-card-costs"]')

    expect(kpi_kol).to have_content('2')
    expect(kpi_impression).to have_content('38.192.664')
    expect(kpi_reach).to have_content('19.345.470')
    expect(kpi_budget).to have_content('Rp54')

    # TODO: use real data by setting the sell price
    expect(kpi_costs).to have_content('Rp0')

    # Remove KOL
    click_on "Done"

    tasya_three_dots = page.find(:xpath, '/html/body/main/section/div[3]/div/div[2]/table/tbody/tr[1]/td[19]/a/i')
    tasya_three_dots.click
    page.find('.remove-kol').click
    # tasya_remove_button.click
    # click ok on confirmation alert
    page.driver.browser.switch_to.alert.accept

    # See the metrics changes
    expect(kpi_kol).to have_content('1')
    expect(kpi_impression).to have_content('36.285.612')
    expect(kpi_er).to have_content('0,75%')
    expect(kpi_reach).to have_content('13.024.524')
    expect(kpi_budget).to have_content('Rp27')
    expect(kpi_costs).to have_content('Rp0')
  end

  def create_new_campaign
    click_on 'New Campaign'

    fill_in 'Name', with: 'Campaign 1'
    select brand.name, from: 'Brand'
    select 'Instagram', from: 'Platform'
    fill_in 'Start at', with: 1.day.ago
    fill_in 'End at', with: 2.day.from_now
    select 'Draft', from: 'Status'
    fill_in 'Budget from brand', with: budget_from_brand
    fill_in 'Internal Budget', with: budget
    fill_in 'Kpi number of social media accounts', with: kpi_number_of_social_media_accounts
    fill_in 'Kpi reach', with: kpi_reach
    fill_in 'Kpi impression', with: kpi_impression
    fill_in 'Kpi engagement rate', with: kpi_engagement_rate
    fill_in 'Kpi cpv', with: kpi_cpv
    fill_in 'Kpi cpr', with: kpi_cpr

    # select2
    find(".select2-selection--multiple").click
    find(".select2-search__field").set('Feed video')
    find(".select2-results__option", text: 'Feed video', match: :prefer_exact).click


    fill_in 'Mediarumu pic name', with: 'Sabrina'
    fill_in 'Mediarumu pic phone', with: '081234567890'
    fill_in 'Notes and media terms', with: 'Notes and media terms'
    fill_in 'Management fees', with: '10'
    fill_in 'Payment terms', with: 'Payment terms'
    fill_in 'Client sign name', with: 'Adittoro'

    click_on 'Buat Campaign'

    expect(page).to have_content('Campaign 1')
    expect(page).to have_content('Brand')
    expect(page).to have_content('draft')
  end
end
