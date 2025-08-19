class AddUserEmailToTrackedRequestsByDaySite < ActiveRecord::Migration[8.0]
  def change
    add_column :tracked_requests_by_day_site, :user_email, :string
  end
end
