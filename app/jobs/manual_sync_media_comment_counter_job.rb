# frozen_string_literal: true

class ManualSyncMediaCommentCounterJob < ApplicationJob
  queue_as :manual_sync_media_comments_counter

  def perform(media_comment_id)
    MediaComment.counter_culture_fix_counts

    media_comment = MediaComment.find(media_comment_id)

    # Sync the last publication history for CRB metric
    last_history = media_comment.publication_histories.last
    return false if last_history.blank?

    social_media_publication = SocialMediaPublication.find(media_comment.social_media_publication_id)
    last_history.update!(
      comments_count: social_media_publication.media_comments_count,
      related_media_comments_count: social_media_publication.related_media_comments_count
    )
  end
end
