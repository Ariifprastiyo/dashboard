class CreateScopeOfWorks < ActiveRecord::Migration[7.0]
  def change
    create_table :scope_of_works do |t|
      t.references :media_plan, null: false, foreign_key: true
      t.references :social_media_account, null: false, foreign_key: true
      t.decimal :total
      t.decimal :rate_card
      t.text :timeline

      t.timestamps
    end
  end
end
