class AddManuallyReviewedAtToMediaComments < ActiveRecord::Migration[7.0]
  def change
    add_column :media_comments, :manually_reviewed_at, :datetime
  end
end
