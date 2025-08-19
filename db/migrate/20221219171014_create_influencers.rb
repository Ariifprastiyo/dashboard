class CreateInfluencers < ActiveRecord::Migration[7.0]
  def change
    create_table :influencers do |t|
      t.string :name
      t.string :phone
      t.string :pic
      t.integer :gender

      t.timestamps
    end
  end
end
