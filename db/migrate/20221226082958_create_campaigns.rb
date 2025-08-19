class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :description
      t.references :brand, null: false, foreign_key: true
      t.integer :status
      t.datetime :start_at
      t.datetime :end_at
      t.decimal :budget
      t.float :kpi_reach
      t.float :kpi_impression
      t.float :kpi_engagement_rate
      t.decimal :kpi_cpv
      t.decimal :kpi_cpr
      t.integer :platform

      t.timestamps
    end
  end
end
