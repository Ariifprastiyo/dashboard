class CreatePublicationAssociations < ActiveRecord::Migration[8.0]
  def change
    create_table :publication_associations do |t|
      t.references :social_media_publication
      t.references :associable, polymorphic: true
      t.timestamps
    end

    # Add indexes
    add_index :publication_associations, [:social_media_publication_id, :associable_type, :associable_id], 
              unique: true, 
              name: 'index_publication_associations_uniqueness'
  end
end 