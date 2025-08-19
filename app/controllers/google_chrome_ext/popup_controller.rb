# frozen_string_literal: true

class GoogleChromeExt::PopupController < ApplicationController
  before_action :authenticate_user!

  before_action -> { check_user_roles(:kol) }


  layout 'popup'

  def index
    @tiktok_username = params[:tiktok_username]
    @tiktok_video_id = params[:tiktok_video_id]

    if @tiktok_username == "null" || @tiktok_video_id == "null"
      render plain: 'Please go to TikTok post page', status: :bad_request
      return
    end

    @social_media_account = SocialMediaAccount.find_by(username: @tiktok_username)
    @social_media_publication = SocialMediaPublication.find_by(url: @tiktok_video_id)
  end

  def import_social_media_account
    influencer, _ = Influencer.find_or_create_by_username(params[:tiktok_username], "tiktok")

    redirect_to google_chrome_ext_popup_index_path(tiktok_username: influencer.name, tiktok_video_id: params[:tiktok_video_id]), notice: 'Social media account imported successfully 🎉'
  end

  def new_post_campaign
    @campaigns = Campaign.active.with_selected_media_plan.order(created_at: :desc)
    @tiktok_username = params[:tiktok_username]
    @tiktok_video_id = params[:tiktok_video_id]
  end

  def create_post_campaign
    @campaign = Campaign.find(params[:campaign_id])
    @media_plan = @campaign.selected_media_plan
    @social_media_account = SocialMediaAccount.find_by(username: params[:tiktok_username])

    if @media_plan.nil?
      redirect_to google_chrome_ext_popup_new_post_campaign_path(tiktok_username: params[:tiktok_username], tiktok_video_id: params[:tiktok_video_id]), alert: 'No selected media plan for this campaign'
      return
    end

    ActiveRecord::Base.transaction do
      # Find or create scope of work
      @scope_of_work = @media_plan.scope_of_works.find_or_create_by!(social_media_account: @social_media_account) do |sow|
        sow.status = 'pending'
      end

      # Find or create scope of work item (assuming it's a video for TikTok)
      @scope_of_work_item = @scope_of_work.scope_of_work_items.find_or_create_by!(name: 'feed_video') do |item|
        item.quantity = 1
        item.price = @social_media_account.feed_video_price
        item.sell_price = @social_media_account.feed_video_sell_price
      end

      # Create SocialMediaPublication
      @social_media_publication = SocialMediaPublication.create!(
        scope_of_work: @scope_of_work,
        scope_of_work_item: @scope_of_work_item,
        social_media_account: @social_media_account,
        campaign: @campaign,
        url: params[:tiktok_video_id],
        platform: 'tiktok'
      )

      @scope_of_work_item.update!(posted_at: Time.current)
      @scope_of_work.calculate_budget_spent
    end

    redirect_to google_chrome_ext_popup_index_path(tiktok_username: params[:tiktok_username], tiktok_video_id: params[:tiktok_video_id]), notice: 'Post created successfully 🎉'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_post_campaign_google_chrome_ext_popup_index_path(tiktok_username: params[:tiktok_username], tiktok_video_id: params[:tiktok_video_id]), alert: "Failed to create post: #{e.message}"
  end
end
