# frozen_string_literal: true

class MediaComment < ApplicationRecord
  include Platformable

  belongs_to :social_media_publication
  has_many :publication_histories, through: :social_media_publication, dependent: :destroy
  has_one :campaign, through: :social_media_publication

  delegate :keyword, :hashtag, :brand_tiktok, to: :social_media_publication

  before_create :set_comment_related_to_brand_flag

  scope :related_media_comments, -> { where(related_to_brand: true) }
  scope :not_related_media_comments, -> { where(related_to_brand: false) }
  scope :positive, -> { where(sentiment_analysis: 'positive') }
  scope :negative, -> { where(sentiment_analysis: 'negative') }
  scope :neutral, -> { where(sentiment_analysis: 'neutral') }

  counter_culture :social_media_publication
  counter_culture :social_media_publication,
                      column_name: proc { |model| model.related_to_brand? ? 'related_media_comments_count' : nil },
                      column_names: -> { {
                        MediaComment.related_media_comments => :related_media_comments_count
                      }}

  counter_culture %i[social_media_publication campaign]
  counter_culture %i[social_media_publication campaign],
                    column_name: proc { |model| model.related_to_brand? ? 'related_media_comments_count' : nil },
                    column_names: -> { {
                      MediaComment.related_media_comments => :related_media_comments_count
                    }}

  scope :related_to_brand, -> { where(related_to_brand: true) }

  enum :sentiment_analysis, neutral: 0, positive: 1, negative: 2

  validates :content, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["comment_at", "content", "created_at", "id", "id_value", "manually_reviewed_at", "payload", "platform", "platform_id", "related_to_brand", "social_media_publication_id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["campaign", "publication_histories", "social_media_publication"]
  end

  def status
    if related_to_brand?
      return 'related'
    end

    'unrelated'
  end

  def sync_related_to_brand_flag
    set_comment_related_to_brand_flag
    save
  end

  def manually_update_related_to_brand(related_to_brand)
    # Update without triggering callbacks, not triggered the counter_culture
    update_columns(related_to_brand: related_to_brand, manually_reviewed_at: DateTime.now)

    # Trigger the counter_culture fix
    ManualSyncMediaCommentCounterJob.perform_later(id)
  end

  def comment_at_in_human_format
    return nil if comment_at.blank?

    comment_at.strftime('%d %b %Y %H:%M')
  end

  # Public: Returns array of CRB related keywords or flags
  def crb_keywords
    flags = []
    flags.push(*keyword.split(',')) if keyword.present?
    flags.push brand_tiktok if brand_tiktok.present?
    flags.push hashtag if hashtag.present?
    flags.map(&:downcase).map(&:strip)
  end

  private
    def set_comment_related_to_brand_flag
      if crb_keywords.any? { |word| content.downcase.include?(word) }
        return self.related_to_brand = true
      end

      self.related_to_brand = false
    end
end
