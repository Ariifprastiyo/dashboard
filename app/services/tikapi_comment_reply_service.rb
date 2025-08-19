# frozen_string_literal: true

class TikapiCommentReplyService < HttpService
  def initialize(media_id, comment_id, cursor = nil)
    super
    @media_id = media_id
    @comment_id = comment_id
    @cursor = cursor
  end

  def base_url
    ENV['TIKAPI_API'].freeze
  end

  def relative_url
    '/comment/reply/list'
  end

  def http_method
    'GET'
  end

  def query
    query = { media_id: @media_id, comment_id: @comment_id }
    @cursor.present? ? query.merge(cursor: @cursor) : query
  end

  def headers
    {
      'Content-Type': 'application/json;',
      'X-Api-Key': ENV['TIKAPI_API_KEY'],
      'X-Account-Key': ENV['TIKAPI_ACCOUNT_KEY']
    }
  end
end
