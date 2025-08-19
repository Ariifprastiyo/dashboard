class RemoveSowFkConstraintFromSocialMediaPublication < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :social_media_publications, to_table: :scope_of_works
    change_column_null :social_media_publications, :scope_of_work_id, true
  end
end
