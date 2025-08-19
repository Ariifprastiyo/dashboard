class RenameRelatedBrandToRelatedToBrandInMediaComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :media_comments, :related_brand, :related_to_brand
  end
end
