# frozen_string_literal: true

class GenerateMediaCommentEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(media_comment_id)
    media_comment = MediaComment.find_by(id: media_comment_id)
    return unless media_comment

    media_comment.generate_embedding!
  end
end
