# frozen_string_literal: true

module ActiveTiktok::Drivers
  require 'httparty'

  # https://rapidapi.com/Sonjik/api/tokapi-mobile-version
  class TokapiMobile < Base
    include HTTParty
    base_uri ENV['TOKAPI_MOBILE_API'] || "https://tokapi-mobile-version.p.rapidapi.com"

    def initialize(api_key:)
      @headers = {
        'X-Rapidapi-Key': '6148367cedmsh1381bc326b0f51ap1a7e7djsn92f7f0369693',
        'X-Rapidapi-Host': 'tokapi-mobile-version.p.rapidapi.com',
      } 
    end
    
    def media_by_id(id)
      puts "using tokapi mobile driver"
      url = "/v1/post/#{id}"
 
      response = self.class.get(url, headers: @headers)
 
      handle_response_errors(response)
 
      json = JSON.parse(response.body)
 
      media_from_json(json)
    end
 
    def comments_by_media_id(media_id, cursor = 0)
      url = "/v1/post/#{media_id}/comments?offset=#{cursor}"
      response = fetch_comments_response(url)
      handle_comments_response(response)
      json = JSON.parse(response.body)
 
      if json["comments"].nil? || json["comments"].empty?
        return empty_comments_collection(media_id)
      end
 
      comments = parse_comments(json)
 
      ActiveTiktok::Models::CommentsCollection.new(
        comments: comments,
        media_id: media_id,
        has_more: json["has_more"] == 1,
        cursor: json["cursor"]
      )
    end
 
    # it should add @ to the username if it's not present
    def user_by_username(username)
      username = "@#{username}" if username[0] != "@"
      url = "/v1/user/#{username}"
      json = perform_api_request(url)
      user_from_json(json)
    end
 
    def medias_by_user_id(user_id)
      url = "/v1/post/user/#{user_id}/posts"
      json = perform_api_request(url)
      medias_collection_from_json(json, user_id)
    end
 
 
    private
      def perform_api_request(url)
        response = self.class.get(url, headers: @headers)
        handle_response_errors(response)
        JSON.parse(response.body)
      end
 
      def handle_response_errors(response)
        # user handling
        return response if response.code == 200 && response.body.include?('user')
        raise ::ActiveTiktok::Drivers::MediaNotFoundError if response.body.include?('status_msg":"Invalid parameters"')
        raise ::ActiveTiktok::Drivers::InvalidIdError if response.body.include?('status_msg:"Invalid parameters"')
        raise ::ActiveTiktok::Drivers::MediaNotFoundError if response.code == 403 && response.body.include?('status_code":0')
        raise ::ActiveTiktok::Drivers::UnauthorizedError if response.code == 403
        raise ::ActiveTiktok::Drivers::UserNotFoundError if response.code == 400 && response.body.include?("Can't get the user_id by username")
        raise ::ActiveTiktok::Drivers::ServerError if response.body.include?('3002334') && response.body.include?("Please try again later")
        raise ::ActiveTiktok::Drivers::MediaNotFoundError unless response.body.include?('aweme_detail')
        raise ::ActiveTiktok::Drivers::LimitError if response.code == 429
      end
 
      def media_from_json(json)
        media = json["aweme_detail"]
        stats = media["statistics"]
        engagement_rate = ((stats["digg_count"] + stats["comment_count"] + stats["share_count"]) / stats["play_count"].to_f) * 100
        cover = media["video"]["cover"]["url_list"].first.to_s.freeze
        ::ActiveTiktok::Models::Media.new(
          id: media["aweme_id"],
          post_identifier: media["aweme_id"],
          caption: media["desc"],
          post_created_at: media["create_time"],
          likes_count: stats["digg_count"],
          comments_count: stats["comment_count"],
          shares_count: stats["share_count"],
          impressions: stats["play_count"],
          reach: stats["play_count"],
          engagement_rate: engagement_rate,
          cover: cover,
          payload: json,
          username: media["author"]["unique_id"]
        )
      end
 
      def user_from_json(json)
        user = json["user"]
        ::ActiveTiktok::Models::User.new(
          id: user["uid"],
          username: user["unique_id"],
          full_name: user["nickname"],
          profile_picture: user["avatar_medium"]["url_list"].first,
          bio: user["signature"],
          website: user["bio_url"],
          media_count: user["aweme_count"],
          follows_count: user["following_count"],
          followed_by_count: user["follower_count"]
        )
      end
 
      def medias_collection_from_json(json, user_id)
        medias = json["aweme_list"].map do |media|
          stats = media["statistics"]
          engagement_rate = ((stats["digg_count"] + stats["comment_count"] + stats["share_count"]) / stats["play_count"].to_f) * 100
          cover = media["video"]["cover"]["url_list"].first.to_s.freeze
 
          ActiveTiktok::Models::Media.new(
            id: media["aweme_id"],
            post_identifier: media["aweme_id"],
            caption: media["desc"],
            post_created_at: media["create_time"],
            likes_count: stats["digg_count"],
            comments_count: stats["comment_count"],
            shares_count: stats["share_count"],
            impressions: stats["play_count"],
            reach: stats["play_count"],
            engagement_rate: engagement_rate,
            cover: cover,
            payload: media
          )
        end
 
        ActiveTiktok::Models::MediasCollection.new(
          medias: medias,
          user_id: user_id,
          has_more: json["has_more"],
          cursor: json["max_cursor"]
        )
      end
 
      def handle_comments_response(response)
        raise ::ActiveTiktok::Drivers::UnauthorizedError if response.code == 403
      end
 
      def fetch_comments_response(url)
        self.class.get(url, headers: @headers)
      end
 
      def empty_comments_collection(media_id)
        ActiveTiktok::Models::CommentsCollection.new(
          media_id: media_id,
          has_more: false,
          comments: [],
          cursor: 0)
      end
 
      def parse_comments(json)
        json["comments"].map do |comment|
          ::ActiveTiktok::Models::Comment.new(
            id: comment["cid"],
            text: comment["text"],
            created_at: comment["create_time"],
            username: comment["user"]["nickname"],
            payload: comment
          )
        end
      end
  end
end