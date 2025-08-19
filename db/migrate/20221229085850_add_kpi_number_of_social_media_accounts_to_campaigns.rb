class AddKpiNumberOfSocialMediaAccountsToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :kpi_number_of_social_media_accounts, :integer
  end
end
