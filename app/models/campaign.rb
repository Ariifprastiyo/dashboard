# frozen_string_literal: true

class Campaign < ApplicationRecord
  include Platformable
  include Discard::Model
  include GenerateCsv

  # to allow form to submit the selected rate price, it will be modify latter in this code
  attr_accessor :selected_show_rate_prices

  # relationships
  belongs_to :brand
  belongs_to :organization, optional: true
  has_many :media_plans, dependent: :destroy
  has_many :social_media_publications, dependent: :destroy # keep for backward compatibility
  has_many :publication_associations, as: :associable
  has_many :publications, through: :publication_associations, source: :associable, source_type: 'SocialMediaPublication'
  has_many :media_comments, through: :social_media_publications
  has_many :publication_histories
  has_many :media_comments, through: :social_media_publications
  has_many :bulk_publications, dependent: :destroy
  has_and_belongs_to_many :competitor_reviews

  has_one_attached :word_cloud_image

  # Yes it's a bit weird that we have a campaign that belongs to a media plan
  # but the purpose of this is to allow us to select the MAIN/SELECTED media plan for a campaign
  belongs_to :selected_media_plan, optional: true, class_name: "MediaPlan", foreign_key: "selected_media_plan_id"

  # validations
  validates :name, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true, comparison: { greater_than_or_equal_to: :start_at }
  validates :status, presence: true
  validates :kpi_engagement_rate, presence: true, numericality: true
  validates :kpi_number_of_social_media_accounts, presence: true, numericality: true
  validates :kpi_impression, presence: true, numericality: true
  validates :kpi_reach, presence: true, numericality: true
  validates :budget, presence: true, numericality: true
  validates :kpi_cpr, presence: true, numericality: true
  validates :kpi_cpv, presence: true, numericality: true
  validates :kpi_crb, presence: true, numericality: true

  delegate :name, to: :brand, prefix: true

  enum :status, draft: 0, active: 1, completed: 2, failed: 3

  scope :with_selected_media_plan, -> { where.not(selected_media_plan_id: nil) }

  after_commit :recalculate_crb_when_hastag_or_keyword_changes, on: %i[update]

  def self.ransackable_attributes(auth_object = nil)
    ["brand_id", "budget", "budget_from_brand", "client_sign_name", "comments_count", "created_at", "description", "discarded_at", "end_at", "engagement_rate", "hashtag", "id", "id_value", "impressions", "invitation_expired_at", "keyword", "kpi_cpe", "kpi_cpr", "kpi_cpv", "kpi_crb", "kpi_engagement_rate", "kpi_impression", "kpi_number_of_social_media_accounts", "kpi_reach", "likes_count", "management_fees", "media_comments_count", "mediarumu_pic_name", "mediarumu_pic_phone", "name", "notes_and_media_terms", "payment_terms", "platform", "reach", "related_media_comments_count", "selected_media_plan_id", "share_count", "show_rate_price_comment", "show_rate_price_feed_photo", "show_rate_price_feed_video", "show_rate_price_host", "show_rate_price_link_in_bio", "show_rate_price_live", "show_rate_price_live_attendance", "show_rate_price_other", "show_rate_price_owning_asset", "show_rate_price_photoshoot", "show_rate_price_reel", "show_rate_price_story", "show_rate_price_story_session", "show_rate_price_tap_link", "start_at", "status", "updated_at", "updated_target_plan_for_reach", "comment_ai_prompt", "comment_ai_analysis", "comment_ai_payload_result"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["brand", "bulk_publications", "media_plans", "publication_histories", "selected_media_plan", "social_media_publications"]
  end

  def comment_related_to_brand_percentage
    return 0 if self.media_comments_count == 0

    self.related_media_comments_count.to_f / self.media_comments_count.to_f * 100
  end

  def recalculate_metrics(*args)
    reload
    calculate_comments_count
    calculate_likes_count
    calculate_share_count
    calculate_impressions
    calculate_reach
    calculate_engagement_rate
    save
  end

  def calculate_comments_count
    self.comments_count = social_media_publications.sum(:comments_count)
  end

  def updated_target_plan_for_reach_in(date)
    return nil if updated_target_plan_for_reach.blank?

    plan = updated_target_plan_for_reach[date]
    return nil if plan.blank?

    plan
  end

  def calculate_likes_count
    self.likes_count = social_media_publications.sum(:likes_count)
  end

  def calculate_share_count
    self.share_count = social_media_publications.sum(:share_count)
  end

  def calculate_impressions
    self.impressions = social_media_publications.sum(:impressions)
  end

  def calculate_reach
    self.reach = social_media_publications.sum(:reach)
  end

  def calculate_engagement_rate
    # The formula is (likes + comments + shares) / impressions
    if impressions.zero?
      self.engagement_rate = 0
    else
      self.engagement_rate = ((likes_count + comments_count + share_count) / impressions.to_f) * 100
    end
  end

  def er_progress
    return 0 if kpi_engagement_rate.blank? || kpi_engagement_rate.zero?

    self.engagement_rate / kpi_engagement_rate.to_f * 100
  end

  def kpi_crb_progress
    # Prevent devide by zero
    return 0 if kpi_crb.to_f == 0

    self.comment_related_to_brand_percentage / kpi_crb.to_f * 100
  end

  def reach_progress
    return 0 if kpi_reach.blank? || kpi_reach.zero?

    self.reach / kpi_reach.to_f * 100
  end

  def impressions_progress
    return 0 if kpi_impression.blank? || kpi_impression.zero?

    self.impressions / kpi_impression.to_f * 100
  end

  # cost per reach is achieved 100% when the cost per reach is equal or less than the KPI
  def kpi_cpr_progress
    return 0 if kpi_cpr.blank? || kpi_cpr.zero?
    return 0 if self.cpr.blank? || self.cpr.zero?

    return 100 if self.cpr <= kpi_cpr

    (kpi_cpr / self.cpr) * 100
  end

  ##
  # Cost per view is the total cost of the campaign divided by the total number of views
  # exclusive for TikTok
  def cpv
    return 0 if self.impressions == 0
    budget_spent_sell_price / self.impressions.to_f
  end

  ##
  # Cost per reach is the total cost of the campaign divided by the total number of reach
  # Exclusive for Instagram
  def cpr
    return 0 if self.reach == 0
    budget_spent_sell_price / self.reach.to_f
  end

  ##
  # Alias for cpr as the clients wants to see it cpi
  # to avoid confusion, we will use cpi as the alias
  def cpi
    cpv
  end

  ##
  # This is alias for either cpr or cpv based on the platform
  def cpi_or_cpv
    instagram? ? cpi : cpv
  end

  ##
  # Cost per engagement is the total cost of the campaign divided by the total number of engagement
  # Applies for all platforms
  def cpe
    return 0 if engagement == 0
    budget_spent_sell_price / engagement.to_f
  end

  ##
  # Total engagement in a campaign
  def engagement
    self.likes_count + self.comments_count + self.share_count
  end

  ##
  # Total number of related / relevant comments to brand in campaign
  def crb
    comment_related_to_brand_percentage
  end

  ##
  # Total budget spent from scope of work items
  def budget_spent
    return 0 if self.selected_media_plan.nil?

    self.selected_media_plan.scope_of_works.sum(:budget_spent)
  end

  def budget_remaining
    return 0 if self.selected_media_plan.nil?

    self.budget - self.budget_spent
  end

  def budget_spent_sell_price
    return 0 if self.selected_media_plan.nil?

    self.selected_media_plan.scope_of_works.sum(:budget_spent_sell_price)
  end

  def budget_remaining_sell_price
    return 0 if self.selected_media_plan.nil?

    self.budget_from_brand - self.budget_spent_sell_price
  end

  ##
  # Total Reach in time range, based on publication histories
  # in a given time range
  def total_reach_in(start_date, end_date)
    return 0 if self.selected_media_plan.nil?

    PublicationHistory.where(id: newest_publication_history_ids(start_date, end_date)).sum(:reach)
  end

  ##
  # Total budget spent sell price, based on scope of works
  # in a given time range
  def total_budget_spent_sell_price_in(start_data, end_date)
    return 0 if self.selected_media_plan.nil?

    self.selected_media_plan.scope_of_works.where(created_at: start_data..end_date).sum(:budget_spent_sell_price)
  end

  # Calculates the number of remaining days for the campaign.
  #
  # Returns an integer representing the number of remaining days.
  def remaining_days
    (end_at.to_date - Date.today).to_i
  end

  ##
  # Total engagement based on publication histories like, comment, share
  # in a given time range
  def total_engagement_in(start_date, end_date)
    return 0 if self.selected_media_plan.nil?

    self.publication_histories.where(id: newest_publication_history_ids(start_date, end_date)).sum('likes_count + comments_count + share_count')
  end

  ##
  # Total Cost per enggament based on publication histories
  # in a given time range
  def total_cpe_in(start_data, end_date)
    return 0 if self.selected_media_plan.nil?

    budget = total_budget_spent_sell_price_in(start_data, end_date)
    engagement = total_engagement_in(start_data, end_date)

    return 0 if engagement == 0

    budget / engagement.to_f
  end

  ##
  # Total Cost per Reach based on publication histories
  # in a given time range
  def total_cpr_in(start_data, end_date)
    return 0 if self.selected_media_plan.nil?

    budget = total_budget_spent_sell_price_in(start_data, end_date)
    reach = total_reach_in(start_data, end_date)

    return 0 if reach == 0

    budget / reach.to_f
  end

  ##
  # Total comments related to brand in a given time range
  def total_crb_in(start_date, end_date)
    return 0 if self.selected_media_plan.nil?

    comments_count = total_comments_in(start_date, end_date)
    related_media_comments_count = total_related_media_comments_in(start_date, end_date)

    return 0 if comments_count == 0

    related_media_comments_count.to_f / comments_count.to_f * 100
  end

  def total_comments_in(start_date, end_date)
    return 0 if self.selected_media_plan.nil?

    self.publication_histories.newest_publication_histories(start_date, end_date).sum(:comments_count)
  end

  def total_related_media_comments_in(start_date, end_date)
    return 0 if self.selected_media_plan.nil?

    self.publication_histories.newest_publication_histories(start_date, end_date).sum(:related_media_comments_count)
  end

  # TODO: need to implement to other relationships
  def discard_with_dependencies
    ActiveRecord::Base.transaction do
      self.discard
    end
  end

  def sync_all_publications
    self.social_media_publications.each do |publication|
      SingleSocialMediaPublicationUpdaterJob.perform_later(publication.id)
      # publication.sync_daily_update(force: true)
    end
  end

  # This part is AI experiment 🧠 🤖
  def analyze_comment_with_openai
    prompt = "Please analyze the following comments about #{comment_ai_prompt} and classify each one as 'Positive', 'Negative', or 'Neutral'. Everything that is not negative will be considered as positive, including emoji positivity, praises, and positive words. Please becareful with the negative words, if you see any negative words and sarcasm please classify it as negative. Additionally, provide a summary conclusion based on the overall sentiment of the comments. The response should be in JSON format with the following structure: {'classifications': [{'id': integer, 'classification': 'Positive | Negative | Neutral'}, ...], 'conclusion': 'string'}. Please respond in plain json"

    # Get all comments with more than 10 characters
    all_comments = media_comments # .where("LENGTH(content) > ?", 10)

    # Process in batches of 200
    all_conclusions = []
    all_classifications = []

    all_comments.in_batches(of: 200) do |batch|
      comments = batch.collect { |x| [id: x.id, comment: x.content] }

      content = {
        "prompt": prompt,
        "comments": comments
      }

      result = fetch_ai_response(content, :comment_ai_payload_result)

      all_conclusions << result["conclusion"]
      all_classifications.concat(result["classifications"])

      # Update comments sentiment analysis for this batch
      grouped_data = result["classifications"].group_by { |item| item["classification"] }
      grouped_data.each do |classification, items|
        ids = items.map { |item| item["id"] }
        MediaComment.where(id: ids).update_all(sentiment_analysis: classification.downcase)
      end
    end

    # Combine all conclusions into a final summary
    final_conclusion = all_conclusions.join(" ")
    # ask openAI to conclude the final_conclusion that might still have redudancy
    finalize_conclusion_prompt = "please make summarize this analysis to have remove redundancy but do not remove any information in there, please elaborate a little bit. please just response without introduction and conclusion, just the final string. please format the string with MD format with grouping and bullet points if necessary so it can be viewed nicely. text to be edited : #{final_conclusion}"

    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{
          role: "user",
          content: finalize_conclusion_prompt
        }],
        temperature: 0.7
      }
    )
    Rails.logger.info "OpenAI Response for conclusion: #{response.inspect}"
    final_conclusion = response.dig("choices", 0, "message", "content").strip


    update(comment_ai_analysis: final_conclusion)


    # Return the combined results
    {
      "classifications" => all_classifications,
      "conclusion" => final_conclusion
    }
  end

  def create_word_cloud_comments_with_openai(prompt = nil)
    prompt ||= "please make a word cloud indicating which word of interest appears, please avoid tracking unnecessary word or phrase. also please make similar meaning words into one word, like inline skate, inlineskate, inline, skate to just inlineskate. Also group words with less count into one word that has similar meaning."

    prompt = "#{prompt}. The response should be in JSON format with the following structure: {'word':count}.Please respond in plain json"

    # Get comments with more than 10 characters
    comments = media_comments.where("LENGTH(content) > ?", 10).limit(300).collect { |x| [id: x.id, comment: x.content] }

    content = {
      "prompt": prompt,
      "comments": comments
    }

    result = fetch_ai_response(content, :word_cloud_payload_result)

    # sort result hash by its value
    result = result.sort_by { |word, count| count }.reverse.to_h
    update(word_cloud: result)

    # generate word cloud image
    word_cloud_generator = WordCloudGeneratorService.new
    word_cloud_image_path = word_cloud_generator.call(result)

    # deattach the previous word cloud image if it exists
    word_cloud_image.purge if word_cloud_image.attached?

    # attach the new word cloud image
    word_cloud_image.attach(io: File.open(word_cloud_image_path), filename: "#{id}_#{name}_word_cloud.png")
    File.delete(word_cloud_image_path) if File.exist?(word_cloud_image_path)
  end

  def sorted_word_cloud
    return {} if word_cloud_payload_result.blank?

    JSON.parse(word_cloud_payload_result).sort_by { |word, count| count }.reverse.to_h
  end
  # End of AI experiment 🧠 🤖

  private
    def newest_publication_history_ids(start_date, end_date)
      self.publication_histories
       .where(created_at: start_date..end_date)
       .select('MAX(id)')
       .group(:social_media_publication_id)
    end

    def recalculate_crb_when_hastag_or_keyword_changes
      if previous_changes.key?('keyword') || previous_changes.key?('hashtag')
        ManuallySyncCampaignCrbMetricJob.perform_later(self.id)
      end
    end

    def fetch_ai_response(content, payload_field)
      # Log the prompt content
      Rails.logger.info("Prompt content: #{content}")

      client = OpenAI::Client.new

      ai_response = client.chat(parameters: { model: "gpt-4o", messages: [{ role: 'user', content: content.to_s }], temperature: 0.7 })

      result = ai_response.dig("choices", 0, "message", "content")

      result = result.gsub(/json/, "").gsub(/```/, "")

      Rails.logger.info("AI response: #{result}")

      # update the payload field with the result
      update(payload_field => result)

      JSON.parse(result)
    end
end
