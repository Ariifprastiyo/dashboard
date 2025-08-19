class AddScopeOfWorkIdToSocialMediaPublication < ActiveRecord::Migration[7.0]
  def change
    add_reference :social_media_publications, :scope_of_work, null: false, foreign_key: true
  end
end
