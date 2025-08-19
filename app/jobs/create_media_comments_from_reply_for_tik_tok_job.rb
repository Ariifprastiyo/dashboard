# frozen_string_literal: true

class CreateMediaCommentsFromReplyForTikTokJob < ApplicationJob
  queue_as :default

  def perform(social_media_publication_id, comment_id)
    publication = SocialMediaPublication.find_by(id: social_media_publication_id, platform: :tiktok)
    media_id = publication.post_identifier
    replies = TikapiCommentReplyService.new(media_id, comment_id).call

    if replies[:status] == 'error'
      raise "TikTok API Error: #{replies[:message]}"
    end

    return false if replies[:comments].blank?

    replies[:comments].each do |reply|
      publication.create_media_comment_for_tiktok(reply)
    end
  end
end
