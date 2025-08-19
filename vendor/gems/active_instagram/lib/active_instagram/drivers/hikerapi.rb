# frozen_string_literal: true

module ActiveInstagram
  module Drivers
    # The LamadavaDriver class provides an interface for interacting with the Instagram API.
    class Hikerapi
      include HTTParty
      base_uri 'https://api.hikerapi.com'

      # initialize with an api_key
      def initialize(api_key:)
        @headers = {
          'x-access-key' => api_key,
          'accept' => 'application/json'
        }
      end

      def profile_by_username(username)
        url = "/a2/user?username=#{username}"

        response = self.class.get(url, headers: @headers)

        raise ::ActiveInstagram::Drivers::ProfileNotFoundError if response.code == 404
        raise ServerError if response.code.to_s.start_with?('5')
        raise ::ActiveInstagram::Drivers::ProfileIsPrivateError if response.code == 403

        json_response = JSON.parse(response.body)
        profile_form_json(username: username, json_response: json_response)
      end

      def media_by_code(code)
        url = "/v1/media/by/code?code=#{code}"

        response = self.class.get(url, headers: @headers)

        raise ::ActiveInstagram::Drivers::MediaNotFoundError if response.code == 404
        raise ::ActiveInstagram::Drivers::ServerError if response.code.to_s.start_with?('5')

        media_form_json(JSON.parse(response.body))
      end

      def medias_by_user_id(user_id, page = nil)
        url = "/v2/user/medias?user_id=#{user_id}&page=#{page}"

        response = self.class.get(url, headers: @headers)

        if response['response'].nil?
          return []
        end

        medias_from_json(response['response']['items'])
      end

      def comments_by_media_id(media_id, page_id = nil)
        url = "/v2/media/comments?id=#{media_id}&page_id=#{page_id}"

        response = self.class.get(url, headers: @headers)

        if response.code == 404 || response.code == 400
          return []
        elsif response.code.to_s.start_with?('5')
          raise ::ActiveInstagram::Drivers::ServerError
        end

        # Extract comments from the response
        hikerapi_comments = response['response']['comments']

        comments = []
        hikerapi_comments.each do |comment|
          c = Comment.new(
            pk: comment['pk'],
            text: comment['text'],
            created_at: Time.at(comment['created_at']),
            user: User.new(
              id: comment['user']['id'],
              username: comment['user']['username'],
              full_name: comment['user']['full_name'],
              profile_picture: comment['user']['profile_pic_url'],
              bio: '',
              website: '',
              media_count: 0,
              follows_count: 0,
              followed_by_count: 0
            )
          )
          comments << c
        end

        # Extract meta data from the response
        next_page_id = response['next_page_id']

        { comments: comments, meta: { next_page_id: next_page_id } }
      end

      private
        def profile_form_json(username:, json_response:)
          user = extract_user(username, json_response)
          medias = extract_medias(json_response)
          Profile.new(user: user, medias: medias)
        end

        def media_form_json(media)
          # tricky taken_at
          begin
            taken_at = DateTime.parse(media['taken_at'])
          rescue TypeError
            taken_at = Time.at(media['taken_at'])
          end
          Media.new(
              id: media['id'],
              pk: media['pk'],
              shortcode: media['code'],
              taken_at: taken_at,
              comments_disabled: media['comments_disabled'],
              display_url: media['display_url'],
              thumbnail_url: media['thumbnail_url'],
              video_url: media['video_url'],
              product_type: media['product_type'],
              title: media['title'],
              video_duration: media['video_duration'],
              video_view_count: media['play_count'],
              caption: media['caption_text'],
              likes_count: media['like_count'],
              comments_count: media['comment_count'],
              username: media['user']['username']
            )
        end

        def medias_from_json(medias)
          medias.map do |media|
            media_form_json(media)
          end
        end

        def extract_user(username, json_response)
          user_data = json_response['graphql']['user']

          User.new(
            id: user_data['id'],
            username: username,
            full_name: user_data['full_name'],
            profile_picture: user_data['profile_pic_url'],
            bio: user_data['biography'],
            website: '', # Assuming website is not provided in the response
            media_count: user_data['edge_owner_to_timeline_media']['count'],
            follows_count: user_data['edge_follow']['count'],
            followed_by_count: user_data['edge_followed_by']['count']
          )
        end

        # We can't refactor it because the response is different from the Instagram API
        # Profie vs Media API result are different
        def extract_medias(json_response)
          user_data = json_response['graphql']['user']
          medias = []

          user_data['edge_owner_to_timeline_media']['edges'].map do |media|
            medias << Media.new(
              id: media['node']['id'],
              pk: media['node']['pk'],
              shortcode: media['node']['shortcode'],
              taken_at: nil,
              display_url: media['node']['display_url'],
              thumbnail_url: media['node']['thumbnail_url'],
              video_url: media['node']['video_url'],
              product_type: media['node']['product_type'],
              title: media['node']['title'],
              video_duration: media['node']['video_duration'],
              video_view_count: media['node']['video_view_count'],
              caption: media['node']['edge_media_to_caption']['edges'].first['node']['text'],
              comments_count: media['node']['edge_media_to_comment']['count'],
              comments_disabled: nil,
              likes_count: media['node']['edge_liked_by']['count'],
            )
          end
          medias
        end
    end
  end
end
