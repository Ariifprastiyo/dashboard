# frozen_string_literal: true

class CreateMediaCommentsAndPublicationHistoryForTiktokJob < ApplicationJob
  HAS_MORE_DATA = 1

  queue_as :default

  include GoodJob::ActiveJobExtensions::Concurrency

  # Actually the limit is 180 per-minute, BUT this job will generate another job to run and thus hit the limit.
  good_job_control_concurrency_with(perform_throttle: [2, 1.second])

  def perform(social_media_publication_id)
    publication = SocialMediaPublication.find_by(id: social_media_publication_id, platform: :tiktok)

    if publication.nil?
      Sentry.capture_message("Social media publication #{social_media_publication_id} not found for Tiktok")
      return
    end

    fetch_comments(publication)
    create_publication_history(publication)
  end


  def fetch_comments(publication)
    media_id = publication.post_identifier
    cursor = 0
    had_stored_comment = false
    duplicate_comments_count = 0

    loop do
      # Stop loop when we have reached the limit
      publication.reload
      break if publication.media_comments_count >= 300

      comments_collection = ActiveTiktok.comments_by_media_id(media_id, cursor)
      puts("=============> Fetching comments for media_id: #{media_id}, cursor: #{cursor}, has_more: #{comments_collection.has_more}")

      # break if comments is nil
      if comments_collection.comments.blank?
        puts("=============> BREAK : No comments found for media_id: #{media_id}. CURSOR: #{cursor}")
        break
      end

      # Creates media comments for TikTok data
      comments_collection.comments.each do |comment|
        media_commment = publication.create_media_comment_for_tiktok(comment)

        if media_commment == false
          had_stored_comment = true
          # break
        end

        # TODO: we ignore the reply comment for now
        # next if comment[:reply_comment_total].to_i == 0
        # CreateMediaCommentsFromReplyForTikTokJob.perform_later(publication.id, comment[:cid])
      end

      # Override the cursor to update next page
      cursor = comments_collection.cursor


      # break if we found duplicate comment
      if had_stored_comment
        puts("=============> DETECTED : Duplicate comment found for media_id: #{media_id}")
        duplicate_comments_count += 1

        if duplicate_comments_count > 50
          puts("====> Too many duplicated comments")
          break
        else
          next
        end
      end

      # Stop loop when there is no more data
      has_more = comments_collection.has_more
      unless has_more
        puts("=============> BREAK : No more data found for media_id: #{media_id}")
        break
      end
    end
  end

  def create_publication_history(social_media_publication)
    # need to be reloaded, after comment insertion, it will update its counter cache
    social_media_publication.reload

    PublicationHistory.create_from_social_media_publication(social_media_publication)
  end
end
