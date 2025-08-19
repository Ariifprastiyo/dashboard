class AddScopeOfWorkItemIdToSocialMediaPublication < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :scope_of_work_item_id, :integer
  end
end
