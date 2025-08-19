class CreateCompetitorReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :competitor_reviews do |t|
      t.references :organization, null: true, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
