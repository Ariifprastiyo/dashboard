# frozen_string_literal: true

module ActiveTiktok::Drivers
  require 'httparty'

  class Tikapi < Base
    include HTTParty
    base_uri ENV['TIKAPI_API'] || "https://api.tikapi.io"

    # For private calls, like comments, we need to use the account key
    def initialize(api_key: 'xxx', account_key: 'xxx')
      @headers = {
        'Content-Type': 'application/json;',
        'X-API-KEY': api_key,
        'X-Account-Key': ENV['TIKAPI_ACCOUNT_KEY'] || account_key
      }
    end

    def media_by_id(id)
      url = "/public/video?id=#{id}"
      json = perform_api_request(url)

      media_from_json json
    end

    def comments_by_media_id(id, cursor = 0)
      url = "/user/comment/list?media_id=#{id}&cursor=#{cursor}"
      json = perform_api_request(url)

      comments_collection_from_json(json, id)
    end

    # it should remove @ from the username if it's present
    def user_by_username(username)
      username = username.delete('@') if username[0] == "@"
      url = "/public/check?username=#{username}"
      json = perform_api_request(url)
      user_from_json(json)
    end

    def medias_by_user_id(user_id)
      url = "/public/posts?secUid=#{user_id}"
      json = perform_api_request(url)
      medias_collection_from_json(json)
    end

    private
      def perform_api_request(url)
        response = self.class.get(url, headers: @headers)
        handle_response_errors(response)
        JSON.parse(response.body)
      end

      def handle_response_errors(response)
        raise ::ActiveTiktok::Drivers::MediaNotFoundError if (response.code == 400) && response.body.include?('A valid video ID or short share video link is required.')
        raise ::ActiveTiktok::Drivers::UnauthorizedError if (response.code == 400) && response.body.include?('A valid API Key is required.')
        raise ::ActiveTiktok::Drivers::UnauthorizedError if response.code == 401
        raise ::ActiveTiktok::Drivers::MediaNotFoundError if response.code == 403 && response.body.include?('10204')
        raise ::ActiveTiktok::Drivers::InvalidIdError if response.code == 403 && (response.body.include?('10201'))
        raise ::ActiveTiktok::Drivers::UserNotFoundError if response.code == 403 && (response.body.include?('10202') || response.body.include?('10221'))
        raise ::ActiveTiktok::Drivers::MediaGeneralError if response.code == 403
        raise ::ActiveTiktok::Drivers::RateLimitError if response.code == 429
        raise ::ActiveTiktok::Drivers::ServerError if response.code == 500
      end

      def media_from_json(json)
        media = json["itemInfo"]["itemStruct"]
        create_media_object(media)
      end

      def medias_collection_from_json(json)
        medias = json['itemList'].map { |media| create_media_object(media) }
        cursor = ''
        has_more = true
        user_id = ''

        ActiveTiktok::Models::MediasCollection.new(medias: medias, user_id: user_id, has_more: has_more, cursor: cursor)
      end

      def create_media_object(media)
        stats = media["stats"]
        engagement_rate = ((stats["diggCount"] + stats["commentCount"] + stats["shareCount"]) / stats["playCount"].to_f) * 100
        cover = media["video"]["originCover"].to_s.freeze
        
        ::ActiveTiktok::Models::Media.new(
          id: media["id"],
          post_identifier: media["id"],
          caption: media["desc"],
          post_created_at: media["createTime"],
          likes_count: stats["diggCount"],
          comments_count: stats["commentCount"],
          shares_count: stats["shareCount"],
          impressions: stats["playCount"],
          reach: stats["playCount"],
          engagement_rate: engagement_rate,
          cover: cover,
          payload: media,
          username: media["author"]["uniqueId"]
        )
      end

      def comments_collection_from_json(json, media_id)
        comments = parse_comments(json)
        cursor = parse_cursor(json)

        ActiveTiktok::Models::CommentsCollection.new(
          media_id: media_id,
          comments: comments,
          has_more: json["has_more"] == 1,
          cursor: cursor
        )
      end

      def user_from_json(json)
        user = json["userInfo"]["user"]
        stats = json["userInfo"]["stats"]

        ::ActiveTiktok::Models::User.new(
          id: user["secUid"],
          username: user["uniqueId"],
          full_name: user["nickname"],
          bio: user["signature"],
          followed_by_count: stats["followerCount"],
          follows_count: stats["followingCount"],
          media_count: stats["videoCount"],
          is_verified: user["verified"],
          is_private: user["privateAccount"],
          profile_picture: user["avatarMedium"],
          likes_count: stats["heartCount"])
      end

      def parse_comments(json)
        json["comments"].nil? ? [] : json["comments"].map do |comment|
          ::ActiveTiktok::Models::Comment.new(
            id: comment["cid"],
            text: comment["text"],
            created_at: comment["create_time"],
            username: comment["user"]["nickname"],
            payload: comment
          )
        end
      end

      def parse_cursor(json)
        json["comments"].nil? ? 0 : json["cursor"]
      end
  end
end
