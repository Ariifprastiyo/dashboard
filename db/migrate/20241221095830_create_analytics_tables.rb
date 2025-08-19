class CreateAnalyticsTables < ActiveRecord::Migration[8.0]
  def up
    create_table :tracked_requests_by_day_page do |t|
      t.date :day, null: false
      t.bigint :total, null: false, default: 1
      t.string :url_hostname, null: false
      t.string :url_path, null: false
      t.string :referrer_hostname
      t.string :referrer_path
    end
    add_index :tracked_requests_by_day_page, :day

    create_table :tracked_requests_by_day_site do |t|
      t.date :day, null: false
      t.bigint :total, null: false, default: 1
      t.string :url_hostname, null: false
      t.string :platform
      t.string :browser_engine
    end
    add_index :tracked_requests_by_day_site, :day
  end

  def down
    drop_table :tracked_requests_by_day_page
    drop_table :tracked_requests_by_day_site
  end
end