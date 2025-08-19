class AddOrganizationIdToCampaigns < ActiveRecord::Migration[7.1]
  def change
    add_reference :campaigns, :organization, null: true, foreign_key: true
  end
end
