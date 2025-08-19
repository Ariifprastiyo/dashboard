class AddShowRatePriceToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :show_rate_price_story, :boolean, default: true
    add_column :campaigns, :show_rate_price_story_session, :boolean, default: true
    add_column :campaigns, :show_rate_price_feed_photo, :boolean, default: true
    add_column :campaigns, :show_rate_price_feed_video, :boolean, default: true
    add_column :campaigns, :show_rate_price_reel, :boolean, default: true
    add_column :campaigns, :show_rate_price_live, :boolean, default: true
    add_column :campaigns, :show_rate_price_owning_asset, :boolean, default: true
    add_column :campaigns, :show_rate_price_tap_link, :boolean, default: true
    add_column :campaigns, :show_rate_price_link_in_bio, :boolean, default: true
    add_column :campaigns, :show_rate_price_live_attendance, :boolean, default: true
    add_column :campaigns, :show_rate_price_host, :boolean, default: true
    add_column :campaigns, :show_rate_price_comment, :boolean, default: true
    add_column :campaigns, :show_rate_price_photoshoot, :boolean, default: true
    add_column :campaigns, :show_rate_price_other, :boolean, default: true
  end
end
