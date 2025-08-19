class CreateMediaComments < ActiveRecord::Migration[7.0]
  def change
    create_table :media_comments do |t|
      t.integer :platform
      t.json :payload
      t.boolean :related_brand
      t.text :content
      t.references :social_media_publication, null: false, foreign_key: true
      t.text :platform_id

      t.timestamps
    end
  end
end
