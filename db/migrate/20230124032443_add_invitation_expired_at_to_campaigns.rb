class AddInvitationExpiredAtToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :invitation_expired_at, :datetime
  end
end
