# frozen_string_literal: true

class TiktokMetricsCalculatorService
  def initialize(posts:, user:)
    @posts = posts.medias
    @user = user
  end

  # @posts is an array of ActiveTiktok::Media
  # @user is an ActiveTiktok::User

  def estimated_engagement_rate
    average @posts.map(&:engagement_rate)
  end

  def estimated_likes_count
    average @posts.map(&:likes_count)
  end

  def estimated_comments_count
    average @posts.map(&:comments_count)
  end

  def estimated_share_count
    average @posts.map(&:shares_count)
  end

  def estimated_impression
    average @posts.map(&:impressions)
  end

  def estimated_reach
    estimated_impression
  end

  private
    def average(values)
      values.sum / values.size
    end

    def recent_posts
      0
    end
end
