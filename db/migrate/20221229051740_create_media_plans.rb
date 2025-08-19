class CreateMediaPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :media_plans do |t|
      t.string :name
      t.float :estimated_impression
      t.float :estimated_reach
      t.float :estimated_engagement_rate
      t.float :estimated_engagement_rate_branding_post
      t.decimal :estimated_budget
      t.references :campaign

      t.timestamps
    end
  end
end
