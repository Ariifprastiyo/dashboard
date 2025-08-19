class AddPostedAtAndScheduledAtToSowItems < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_work_items, :posted_at, :datetime
    add_column :scope_of_work_items, :scheduled_at, :datetime
  end
end
