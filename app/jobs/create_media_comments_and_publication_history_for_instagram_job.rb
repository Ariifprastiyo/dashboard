# frozen_string_literal: true

class CreateMediaCommentsAndPublicationHistoryForInstagramJob < ApplicationJob
  queue_as :default

  def perform(social_media_publication_id)
    publication = SocialMediaPublication.find_by(id: social_media_publication_id, platform: :instagram)

    if publication.nil?
      Sentry.capture_message("No publication found with id: #{social_media_publication_id} for platform: instagram")
      return
    end

    # fetch_comments_using_gql(publication)
    fetch_comments(publication)
    create_publication_history(publication)
  end

  # Public: Fetch comments from Lamadava API and store it to database
  #
  # LamaDava API will return 20 comments per request and it is sorted by newest to oldest.
  # Therefore, We can safely assume that if we found a comment that already stored in DB,
  # the rest of the comments also already stored in DB, and we can stop the loop.
  def fetch_comments(publication)
    return if publication.post_identifier.blank?

    # Retrieve IG post/media info
    min_id = publication.last_comment_cursor

    # attempt count, we will set max attempt to 5
    attempt = 0

    loop do
      # Set max data to preparing stop loop when there is no more data
      break if publication.media_comments.count >= 50

      # Set max attempt to 5
      break if attempt >= 5

      # Retrieve IG media comments, starting from min_id
      response = ActiveInstagram.comments_by_media_id(publication.post_identifier, min_id)
      break if response.blank?

      comments = response[:comments]

      comments.each do |comment|
        next if comment.kind_of?(String)
        publication.create_media_comment_for_ig(comment)
      end

      meta_info = response[:meta][:next_page_id]
      min_id = meta_info
      publication.reload
      break if publication.last_comment_cursor.present? && publication.last_comment_cursor == min_id
      publication.update(last_comment_cursor: min_id)
      attempt += 1
    end
  end

  def create_publication_history(social_media_publication)
    # need to be reloaded as fetch comments will update counter cache
    social_media_publication.reload

    PublicationHistory.create_from_social_media_publication(social_media_publication)
  end
end
