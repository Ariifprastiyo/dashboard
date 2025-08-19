# frozen_string_literal: true

class InstagramMetricsCalculatorService
  def initialize(posts:, user:)
    @posts = posts
    @user = user
  end

  def estimated_engagement_rate
    return 0 if @posts.blank?

    # 2nd to 10th posts
    recent_posts = @posts[1..9]

    # calculate engagement rate for each post
    er = []

    recent_posts.each do |post|
      # post = post['node'] if post['node']
      # this was from /a1/
      # er << ((post['edge_liked_by']['count'] + post['edge_media_to_comment']['count']) / @profile["edge_followed_by"]["count"].to_f) * 100
      # er << ((post['likes'].to_i + post['comments'].to_i) / @response_body['followers'].to_f) * 100

      # This is ER by deviding the sum of likes and comments by the number of followers
      # er << ((post.likes_count + post.comments_count) / @user.followed_by_count.to_f) * 100

      # This is ER by deviding the sum of likes and comments by the number of views

      next if post.video_view_count.to_i.zero? || post.taken_at < 3.months.ago
      er << ((post.likes_count + post.comments_count) / post.video_view_count.to_f) * 100
    end

    return 0 if er.blank?

    average(er).to_f
  end

  def estimated_likes_count
    return 0 if @posts.blank?

    # likes = recent_posts.map { |post| post['node']['edge_liked_by']['count'] }
    likes = recent_posts.map { |post| post.likes_count }
    average(likes).to_i
  end

  def estimated_comments_count
    return 0 if @posts.blank?

    comments = recent_posts.map { |post| post.comments_count }
    average(comments).to_i
  end

  def estimated_impression
    return 0 if @posts.blank?

    video_posts = @posts.select { |post| post.video_view_count.to_i > 0 }
    return 0 if video_posts.blank?

    video_posts_views = video_posts.map { |post| post.video_view_count.to_i }

    avg_video_views = average(video_posts_views).to_i

    if avg_video_views.zero?
      estimated_reach
    else
      avg_video_views
    end
  end

  def estimated_reach
    (@user.followed_by_count * 0.4).to_i
  end

  private
    def average(values)
      return 0 if values.blank?
      values.sum / values.length
    end

    def recent_posts
      @posts[1..9]
    end
end
