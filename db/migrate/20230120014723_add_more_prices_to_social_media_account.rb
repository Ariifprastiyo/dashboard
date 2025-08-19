class AddMorePricesToSocialMediaAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_accounts, :tap_link_price, :decimal, default: 0
    add_column :social_media_accounts, :link_in_bio_price, :decimal, default: 0
    add_column :social_media_accounts, :live_attendance_price, :decimal, default: 0
    add_column :social_media_accounts, :host_price, :decimal, default: 0
    add_column :social_media_accounts, :comment_price, :decimal, default: 0
    add_column :social_media_accounts, :photoshoot_price, :decimal, default: 0
    add_column :social_media_accounts, :other_price, :decimal, default: 0
  end
end
