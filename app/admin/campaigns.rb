# frozen_string_literal: true

ActiveAdmin.register Campaign do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  attribute_to_show = :name, :description, :brand_id, :organization_id, :status, :start_at, :end_at, :budget, :kpi_reach,
    :kpi_impression, :kpi_engagement_rate, :kpi_cpv, :kpi_cpr, :platform, :discarded_at, :kpi_number_of_social_media_accounts,
    :mediarumu_pic_name, :mediarumu_pic_phone, :notes_and_media_terms, :payment_terms, :client_sign_name,
    :selected_media_plan_id, :management_fees, :invitation_expired_at, :show_rate_price_story, :show_rate_price_story_session,
    :show_rate_price_feed_photo, :show_rate_price_feed_video, :show_rate_price_reel, :show_rate_price_live,
    :show_rate_price_owning_asset, :show_rate_price_tap_link, :show_rate_price_link_in_bio, :show_rate_price_live_attendance,
    :show_rate_price_host, :show_rate_price_comment, :show_rate_price_photoshoot, :show_rate_price_other, :comments_count,
    :likes_count, :share_count, :impressions, :reach, :engagement_rate, :budget_from_brand, :kpi_cpe, :keyword, :hashtag,
    :media_comments_count, :related_media_comments_count, :kpi_crb, :updated_target_plan_for_reach,
    :comment_ai_analysis, :comment_ai_payload_result, :comment_ai_prompt

  permit_params attribute_to_show
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :description, :brand_id, :status, :start_at, :end_at, :budget, :kpi_reach, :kpi_impression, :kpi_engagement_rate, :kpi_cpv, :kpi_cpr, :platform, :discarded_at, :kpi_number_of_social_media_accounts, :mediarumu_pic_name, :mediarumu_pic_phone, :notes_and_media_terms, :payment_terms, :client_sign_name, :selected_media_plan_id, :management_fees, :invitation_expired_at, :show_rate_price_story, :show_rate_price_story_session, :show_rate_price_feed_photo, :show_rate_price_feed_video, :show_rate_price_reel, :show_rate_price_live, :show_rate_price_owning_asset, :show_rate_price_tap_link, :show_rate_price_link_in_bio, :show_rate_price_live_attendance, :show_rate_price_host, :show_rate_price_comment, :show_rate_price_photoshoot, :show_rate_price_other, :comments_count, :likes_count, :share_count, :impressions, :reach, :engagement_rate, :budget_from_brand, :kpi_cpe, :keyword, :hashtag, :media_comments_count, :related_media_comments_count, :kpi_crb, :updated_target_plan_for_reach]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # Colums to display according to permitted params

  index do
    id_column
    attribute_to_show.each do |attr|
      if [:comment_ai_analysis, :comment_ai_payload_result, :comment_ai_prompt].include?(attr)
        column attr do |campaign|
          campaign.send(attr)&.slice(0, 140)
        end
      else
        column attr
      end
    end
  end

  filter :name
  filter :platform
  filter :start_at
  filter :end_at
  filter :status
  filter :media_comments_count

  member_action :analyze_comment_with_ai, method: :post do
    campaign = Campaign.find(params[:id])
    campaign.analyze_comment_with_openai

    redirect_to admin_campaign_path(campaign), notice: 'Comments are being analyzed with AI.'
  end

  action_item :analyze_comment_with_ai, only: :show do
    link_to 'Analyze with AI', analyze_comment_with_ai_admin_campaign_path(campaign), method: :post, data: { confirm: 'Analyze with AI. Are you sure?' }
  end
end
