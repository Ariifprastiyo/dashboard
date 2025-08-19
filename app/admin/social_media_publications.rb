# frozen_string_literal: true

ActiveAdmin.register SocialMediaPublication do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :post_identifier, :platform, :kind, :url, :post_created_at, :caption, :comments_count, :likes_count, :share_count, :impressions, :reach, :engagement_rate, :last_sync_at, :payload, :social_media_account_id, :campaign_id, :scope_of_work_id, :scope_of_work_item_id, :manual, :media_comments_count, :related_media_comments_count, :last_error_during_sync, :additional_info, :deleted_by_third_party, :saves_count
  #
  # or
  #
  # permit_params do
  #   permitted = [:post_identifier, :platform, :kind, :url, :post_created_at, :caption, :comments_count, :likes_count, :share_count, :impressions, :reach, :engagement_rate, :last_sync_at, :payload, :social_media_account_id, :campaign_id, :scope_of_work_id, :scope_of_work_item_id, :manual, :media_comments_count, :related_media_comments_count, :last_error_during_sync, :additional_info, :deleted_by_third_party, :saves_count]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    id_column
    column :post_identifier
    column :platform
    column :kind
    column :url
    column :post_created_at
    column "Caption" do |publication|
      truncate(publication.caption, length: 50)
    end
    column :impressions
    column :reach
    column :engagement_rate
    column :last_sync_at
    column :social_media_account_id
    column :campaign_id
    column :scope_of_work_id
    column :scope_of_work_item_id
    column :manual
    column :last_error_during_sync
    column :deleted_by_third_party
  end

  filter :campaign_id
  filter :post_identifier
  filter :platform, as: :select, collection: SocialMediaPublication.platforms.keys
  filter :kind
  filter :url
  filter :last_error_during_sync
  filter :deleted_by_third_party
end
