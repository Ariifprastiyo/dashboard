require 'rails_helper'

RSpec.feature "DuringCampaign::AcivityReports", type: :feature do
  describe 'Activity Report' do
    include CompleteBasicSetup

    before do
      admin = create(:admin)
      admin.add_role(:super_admin)
      sign_in admin
    end

    # TODO : complete this important spec
    # make another publiction + publication_history for the next day, check the commulative value on that day

    it 'shows correct info for the 1st day' do
      params = { "q" => { "created_at_gteq" => 2.days.ago, "created_at_lteq" => 2.days.ago, "social_media_account_size_in" => ["0", "1", "2", "3"] } }
      visit campaign_activity_report_path(@campaign, params)

      { "#mega_budget"  => "Rp48.000.000",  "#mega_number_of_kol"   => "2", "#mega_reach"  => 0, "#mega_cpr"  => "Rp0", "#mega_engagement_rate"   => "0,00%", "#mega_cpe"   => "Rp0", "#mega_crb"   => "0,00%",
        "#macro_budget" => "Rp4.800.000",   "#macro_number_of_kol"  => "2", "#macro_reach" => 0, "#macro_cpr" => "Rp0", "#macro_engagement_rate"  => "0,00%", "#macro_cpe"  => "Rp0", "#macro_crb"  => "0,00%",
        "#micro_budget" => "Rp480.000",     "#micro_number_of_kol"  => "2", "#micro_reach" => 0, "#micro_cpr" => "Rp0", "#micro_engagement_rate"  => "0,00%", "#micro_cpe"  => "Rp0", "#micro_crb"  => "0,00%",
        "#nano_budget"  => "Rp48.000",      "#nano_number_of_kol"   => "2", "#nano_reach"  => 0, "#nano_cpr"  => "Rp0", "#nano_engagement_rate"   => "0,00%", "#nano_cpe"   => "Rp0", "#nano_crb"   => "0,00%"
      }. each do |el, value|
        element = page.find(el).text
        expect(element).to have_content(value), "#{el} expected to have #{value} but got #{element}"
      end
    end

    it 'shows correct info for the 2nd day' do
      params = { "q" => { "created_at_gteq" => 1.days.ago, "created_at_lteq" => 1.days.ago, "social_media_account_size_in" => ["0", "1", "2", "3"] } }
      visit campaign_activity_report_path(@campaign, params)

      # ALL ZERO because we skip publication history / not doing daily sync
      { "#mega_budget"  => "Rp0", "#mega_number_of_kol"  => "0", "#mega_reach"  => 0, "#mega_cpr"  => "Rp0", "#mega_engagement_rate"  => "0,00%", "#mega_cpe"   => "Rp0", "#mega_crb"   => "0,00%",
        "#macro_budget" => "Rp0", "#macro_number_of_kol" => "0", "#macro_reach" => 0, "#macro_cpr" => "Rp0", "#macro_engagement_rate" => "0,00%", "#macro_cpe"  => "Rp0", "#macro_crb"  => "0,00%",
        "#micro_budget" => "Rp0", "#micro_number_of_kol" => "0", "#micro_reach" => 0, "#micro_cpr" => "Rp0", "#micro_engagement_rate" => "0,00%", "#micro_cpe"  => "Rp0", "#micro_crb"  => "0,00%",
        "#nano_budget"  => "Rp0", "#nano_number_of_kol"  => "0", "#nano_reach"  => 0, "#nano_cpr"  => "Rp0", "#nano_engagement_rate"  => "0,00%", "#nano_cpe"   => "Rp0", "#nano_crb"   => "0,00%"
      }. each do |el, value|
        element = page.find(el).text
        expect(element).to have_content(value), "#{el} expected to have #{value} but got #{element}"
      end
    end

    it 'shows correct info for today' do
      params = { "q" => { "created_at_gteq" => 2.days.ago, "created_at_lteq" => Date.today, "social_media_account_size_in" => ["0", "1", "2", "3"] } }
      visit campaign_activity_report_path(@campaign, params)

      # Should be comprehensive as we simulate daily sync by creating manual publication history
      { "#mega_budget"  => "Rp48.000.000",  "#mega_number_of_kol"   => "2", "#mega_reach"   => "1.600.000", "#mega_cpr"   => "Rp30",  "#mega_engagement_rate"   => "10,00%", "#mega_cpe"  => "Rp599",    "#mega_crb"   => "33,33%",
        "#macro_budget" => "Rp4.800.000",   "#macro_number_of_kol"  => "2", "#macro_reach"  => "120.000",   "#macro_cpr"  => "Rp40",  "#macro_engagement_rate"  => "10,04%", "#macro_cpe" => "Rp797",    "#macro_crb"  => "27%",
        "#micro_budget" => "Rp480.000",     "#micro_number_of_kol"  => "2", "#micro_reach"  => "8.000",     "#micro_cpr"  => "Rp60",  "#micro_engagement_rate"  => "10,50%", "#micro_cpe" => "Rp1.142",  "#micro_crb" => "20,00%",
        "#nano_budget"  => "Rp48.000",      "#nano_number_of_kol"   => "2", "#nano_reach"   => "4.000",     "#nano_cpr"   => "Rp12",  "#nano_engagement_rate"   => "10,90%", "#nano_cpe"  => "Rp220",  "#nano_crb" => "11%"
      }. each do |el, value|
        element = page.find(el).text
        expect(element).to have_content(value), "#{el} expected to have #{value} but got #{element}"
      end
    end
  end
end
