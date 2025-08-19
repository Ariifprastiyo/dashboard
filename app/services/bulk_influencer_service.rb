# frozen_string_literal: true

class BulkInfluencerService < ApplicationService
  def initialize(bulk_influencer:, row:, index:)
    @data = transform_data(row)
    @index = index + 2 # header and start from 0
    @bulk_influencer = bulk_influencer
  end

  def call
    @bulk_influencer.current_row = @index
    @bulk_influencer.save

    ActiveRecord::Base.transaction do
      influencer = Influencer.kept.find_or_initialize_by(name: @data[:name],
                                                         pic_phone_number: @data[:pic_phone_number],
                                                         gender: format_gender_data,
                                                         pic: @data[:pic], have_npwp: false)

      unless influencer.valid?
        create_error_message(title: 'Influencer Data', message: influencer.errors.full_messages)
        return
      end

      influencer.save! if influencer.new_record?

      create_instagram(influencer)
      create_tiktok(influencer)
    end
  rescue ArgumentError => e
    Sentry.capture_message("Parameter Error: #{e.message}")
    create_error_message(title: 'Parameter Error', message: e.message.to_s)
  rescue StandardError => e
    Sentry.capture_message("Error: #{e.message}")
    create_error_message(title: 'Error', message: e.message.to_s)
  end

  private
    def create_instagram(influencer)
      if @data[:ig_username].present?
        instagram_social_media = build_social_media_account_instagram(influencer)

        unless instagram_social_media.valid?
          message = instagram_social_media.errors.full_messages
          create_error_message(title: "Social Media Account (Instagram) #{instagram_social_media.username}", message: message)
          influencer.destroy unless message.any? { |error| error["has already been taken"] }
          return
        end

        begin
          instagram_social_media.save
        rescue ActiveInstagram::Drivers::ProfileNotFoundError => e
          Sentry.capture_message("Instagram profile not found for username: #{instagram_social_media.username}")
          create_error_message(title: "Instagram Profile Not Found for #{instagram_social_media.username}", message: e.message)
          instagram_social_media.destroy
          influencer.destroy
        rescue ActiveInstagram::Drivers::ServerError => e
          Sentry.capture_message("Instagram server error for username: #{instagram_social_media.username}")
          create_error_message(title: "Instgram Error #{instagram_social_media.username}", message: e.message)
          instagram_social_media.destroy
          influencer.destroy
        end
      end
    end

    def create_tiktok(influencer)
      if @data[:tiktok_username].present?
        tiktok_social_media = build_social_media_account_tiktok(influencer)

        unless tiktok_social_media.valid?
          message = tiktok_social_media.errors.full_messages
          create_error_message(title: "Social Media Account (Tiktok) #{tiktok_social_media.username}", message: message)
          influencer.destroy
          return
        end

        begin
          tiktok_social_media.save
        rescue ActiveTiktok::Drivers::UserNotFoundError => e
          Sentry.capture_message("TikTok profile not found for username: #{tiktok_social_media.username}")
          create_error_message(title: "Tiktok Profile Not Found for #{tiktok_social_media.username}", message: e.message)
          tiktok_social_media.destroy
          influencer.destroy
        rescue ActiveTiktok::Drivers::ServerError => e
          Sentry.capture_message("TikTok server error for username: #{tiktok_social_media.username}")
          create_error_message(title: "Tiktok Server Error #{tiktok_social_media.username}", message: e.message)
          tiktok_social_media.destroy
          influencer.destroy
        end
      end
    end

    def build_social_media_account_instagram(influencer)
      instagram_social_media = influencer.social_media_accounts.new
      instagram_social_media.platform = :instagram
      instagram_social_media.username = @data[:ig_username]
      instagram_social_media.story_price = @data[:ig_story_price] || 0
      instagram_social_media.story_session_price = @data[:ig_story_session_price] || 0
      instagram_social_media.feed_photo_price = @data[:ig_feed_photo_price] || 0
      instagram_social_media.feed_video_price = @data[:ig_feed_video_price] || 0
      instagram_social_media.reel_price = @data[:ig_reel_price] || 0
      instagram_social_media.live_price = @data[:ig_live_price] || 0
      instagram_social_media.estimated_engagement_rate_branding_post = @data[:estimated_engagement_rate_branding_post_instagram].to_f * 100 || 0
      # seed categories
      category_ids = seed_category(@data[:ig_categories])
      instagram_social_media.category_ids = category_ids

      instagram_social_media
    end

    def build_social_media_account_tiktok(influencer)
      tiktok_social_media = influencer.social_media_accounts.new
      tiktok_social_media.platform = :tiktok

      tiktok_social_media.username = @data[:tiktok_username]
      tiktok_social_media.story_price = @data[:tiktok_story_price] || 0
      tiktok_social_media.story_session_price = @data[:tiktok_story_session_price] || 0
      tiktok_social_media.feed_photo_price = @data[:tiktok_feed_photo_price] || 0
      tiktok_social_media.feed_video_price = @data[:tiktok_feed_video_price] || 0
      tiktok_social_media.reel_price = @data[:tiktok_reel_price] || 0
      tiktok_social_media.live_price = @data[:tiktok_live_price] || 0
      tiktok_social_media.estimated_engagement_rate_branding_post = @data[:estimated_engagement_rate_branding_post_tiktok].to_f * 100 || 0

      # seed categories
      category_ids = seed_category(@data[:tiktok_categories])
      tiktok_social_media.category_ids = category_ids

      tiktok_social_media
    end

    def seed_category(data)
      return [] if data.blank?
      categories = data.split(",")

      category_ids = []
      categories.each do |category_name|
        category = Category.find_by(name: category_name.strip)
        return if category.nil?

        category_ids << category.id
      end

      category_ids
    end

    def create_error_message(title:, message:)
      if @bulk_influencer.error_messages.nil?
        @bulk_influencer.error_messages = []
      end

      if @bulk_influencer.total_error.nil?
        @bulk_influencer.total_error ||= 0
      end
      @bulk_influencer.total_error += 1
      @bulk_influencer.error_messages << "#[#{@index}] No. #{@data[:number]} - #{title} can not be stored, message: #{message}"
      @bulk_influencer.save!

      @bulk_influencer
    end

    def format_gender_data
      return if @data[:gender].nil?

      @data[:gender].downcase!
    end

    def transform_data(row)
      data = {}

      data[:number] = row[0]
      data[:name] = row[1].strip if row[1].present?
      data[:pic] = row[2].strip if row[2].present?
      data[:pic_phone_number] = row[3].to_s.strip if row[3].present?
      data[:gender] = row[4].strip if row[4].present?
      data[:ig_username] = row[5].strip.downcase if row[5].present?
      data[:ig_categories] = row[6].strip if row[6].present?
      data[:tiktok_username] = row[7].strip.downcase if row[7].present?
      data[:tiktok_categories] = row[8].strip if row[8].present?
      data[:ig_story_price] = row[9]
      data[:tiktok_story_price] = row[10]
      data[:ig_story_session_price] = row[11]
      data[:tiktok_story_session_price] = row[12]
      data[:ig_feed_photo_price] = row[13]
      data[:tiktok_feed_photo_price] = row[14]
      data[:ig_feed_video_price] = row[15]
      data[:tiktok_feed_video_price] = row[16]
      data[:ig_reel_price] = row[17]
      data[:tiktok_reel_price] = row[18]
      data[:ig_live_price] = row[19]
      data[:tiktok_live_price] = row[20]
      data[:ig_owning_asset_price] = row[21]
      data[:tiktok_owning_asset_price] = row[22]
      data[:ig_tap_link_price] = row[23]
      data[:tiktok_tap_link_price] = row[24]
      data[:ig_link_in_bio_price] = row[25]
      data[:tiktok_link_in_bio_price] = row[26]
      data[:ig_live_attendance_price] = row[27]
      data[:tiktok_live_attendance_price] = row[28]
      data[:ig_host_price] = row[29]
      data[:tiktok_host_price] = row[30]
      data[:ig_comment_price] = row[31]
      data[:tiktok_comment_price] = row[32]
      data[:ig_photoshoot_price] = row[33]
      data[:tiktok_photoshoot_price] = row[34]
      data[:ig_other_price] = row[35]
      data[:tiktok_other_price] = row[36]
      data[:estimated_engagement_rate_branding_post_instagram] = row[37]
      data[:estimated_engagement_rate_branding_post_tiktok] = row[38]

      data
    end
end
