require "active_instagram/client"
require "active_instagram/drivers/hikerapi"

RSpec.describe ActiveInstagram::Drivers::Hikerapi do
  let(:api_key) { "P0SBEUnlcdFLlBfqxAU3XgFyt9VfFmEV" }
  subject { described_class.new(api_key: api_key) }

  describe "#profile_by_username" do
    let(:username) { "adhytia" }
    let(:response)  { double("response", code: '200') }

    it "sends a GET request to the correct URL with the provided username" do
      VCR.use_cassette("hikerapi_profile_by_username") do
        headers = { 'x-access-key' => api_key, 'accept' => 'application/json' }
        url = "/a2/user?username=#{username}"

        expect(described_class).to receive(:get).with(url, headers: headers).and_call_original

        subject.profile_by_username(username)
      end
    end

    context "when user is found" do
      it 'returns a Profile object' do
        VCR.use_cassette("hikerapi_profile_by_username") do
          profile = subject.profile_by_username(username)
          expect(profile).to be_a(ActiveInstagram::Profile)

          user = profile.user

          expect(user.id).to eq("5395579")
          expect(user).to be_a(ActiveInstagram::User)
          expect(user.username).to eq(username)
          expect(user.full_name).to eq("Vina Rafeequl")

          medias = profile.medias
          expect(medias.size).to eq(12)
          expect(medias.first).to be_a(ActiveInstagram::Media)
          expect(medias[2].id).to eq("3320610159940295349")
          expect(medias[2].comments_count).to eq(4)
          expect(medias[2].likes_count).to eq(3)
          expect(medias[2].video_view_count).to eq(0)
        end
      end
    end
  end

  describe "#media_by_code" do
    let(:code) { "C49h0OYPsow" }

    it "sends a GET request to the correct URL with the provided code" do
      VCR.use_cassette("hikerapi_media_by_code") do
        headers = { 'x-access-key' => api_key, 'accept' => 'application/json' }
        url = "/v1/media/by/code?code=#{code}"

        expect(described_class).to receive(:get).with(url, headers: headers).and_call_original

        subject.media_by_code(code)
      end
    end

    context "when media is found" do
      it 'returns a Media object' do
        VCR.use_cassette("hikerapi_media_by_code") do
          media = subject.media_by_code(code)

          expect(media).to be_a(ActiveInstagram::Media)
          expect(media.id).to eq("3331968023710845488_6146863322")
          expect(media.shortcode).to eq("C49h0OYPsow")
          expect(media.taken_at).to eq(DateTime.parse "2024-03-26T02:53:40Z")
          expect(media.display_url).to be_nil
          expect(media.thumbnail_url).to eq("https://scontent-lhr8-1.cdninstagram.com/v/t51.29350-15/434530581_946529373734252_2392265315481725735_n.jpg?stp=dst-jpg_e15&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi43MjB4MTI4MC5zZHIifQ&_nc_ht=scontent-lhr8-1.cdninstagram.com&_nc_cat=108&_nc_ohc=mIMxDTpfzlUAX9CmxJ7&edm=ALQROFkBAAAA&ccb=7-5&ig_cache_key=MzMzMTk2ODAyMzcxMDg0NTQ4OA%3D%3D.2-ccb7-5&oh=00_AfDcMsqEW0AxAcPsqeN-Bo7WWfmZGbxkqirGPv1fx2S-3w&oe=660E959D&_nc_sid=fc8dfb")
          expect(media.video_url).to eq("https://scontent-lhr6-2.cdninstagram.com/o1/v/t16/f1/m69/GICWmABvr0hSVfQDAFEoqbKBuUtqbpR1AAAF.mp4?efg=eyJ2ZW5jb2RlX3RhZyI6InZ0c192b2RfdXJsZ2VuLmNsaXBzLmMyLjEwODAuYmFzZWxpbmUifQ&_nc_ht=scontent-lhr6-2.cdninstagram.com&_nc_cat=105&vs=7678270872203218_3902163537&_nc_vs=HBksFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HSUNXbUFCdnIwaFNWZlFEQUZFb3FiS0J1VXRxYnBSMUFBQUYVAALIAQAVAhg6cGFzc3Rocm91Z2hfZXZlcnN0b3JlL0dIdEl2eGFielBuaFAtVURBTFNTbXNqVTFWRnRicFIxQUFBRhUCAsgBACgAGAAbABUAACbog52cg8njPxUCKAJDMywXQFaEOVgQYk4YFmRhc2hfYmFzZWxpbmVfMTA4MHBfdjERAHX%2BBwA%3D&_nc_rid=b1a54fd885&ccb=9-4&oh=00_AfBiK263mxzHMVLXJJfTMTFjbtypy5Im1JqSjVjrGeM2uw&oe=660AAB41&_nc_sid=fc8dfb")
          expect(media.product_type).to eq("clips")
          expect(media.title).to eq("")
          expect(media.video_duration).to eq(90.066)
          expect(media.video_view_count).to eq(334216)
          expect(media.caption).to eq("CARA SYAR’I MENAIKAN HARGA DIRI\n\nUstadz Muhammad Nuzul Dzikri hafizhahullah\n\nVideo pendek diambil dari Kajian SR:\n“16. Menjadi Mulia Dengan Ketaatan”\nhttps://www.youtube.com/live/WAWJtg8tfb4?si=oJ4ZF2CuAHLS1vGD")
          expect(media.comments_count).to eq(85)
          expect(media.comments_disabled).to eq(false)
          expect(media.likes_count).to eq(23299)
          expect(media.username).to eq("muhammadnuzuldzikri")
        end
      end
    end
  end

  describe "#medias_by_user_id" do
    let(:user_id) { "606119027" }
    let(:page) { nil }

    it "sends a GET request to the correct URL with the provided user_id" do
      VCR.use_cassette("hikerapi_medias_by_user_id") do
        headers = { 'x-access-key' => api_key, 'accept' => 'application/json' }
        url = "/v2/user/medias?user_id=#{user_id}&page=#{page}"

        expect(described_class).to receive(:get).with(url, headers: headers).and_call_original

        subject.medias_by_user_id(user_id, page)
      end
    end

    context "when medias or user are found" do
      it "returns an array of Media objects" do
        VCR.use_cassette("hikerapi_medias_by_user_id") do
          medias = subject.medias_by_user_id(user_id)
          media = medias.first

          expect(medias).to be_an(Array)
          expect(medias.count).to eq(12)
          expect(media).to be_a(ActiveInstagram::Media)
          expect(media.id).to eq("3336393462951286292_606119027")
          expect(media.likes_count).to eq(1863)
          expect(media.comments_count).to eq(76)
          expect(media.video_view_count).to eq(89166)
        end
      end
    end
  end

  describe "#comments_by_media_id" do
    let(:media_id) { "3304874679397943100" }
    it 'sends a GET request to the correct URL with the provided media_id' do
      VCR.use_cassette("hikerapi_comments_by_media_id") do
        headers = { 'x-access-key' => api_key, 'accept' => 'application/json' }
        url = "/v2/media/comments?id=#{media_id}&page_id="

        expect(described_class).to receive(:get).with(url, headers: headers).and_call_original

        subject.comments_by_media_id(media_id)
      end
    end

    it 'returns comments meta data if available' do
      VCR.use_cassette("hikerapi_comments_by_media_id") do
        response = subject.comments_by_media_id(media_id)

        expect(response).to be_a(Hash)
        expect(response[:meta][:next_page_id]).to eq("{\"server_cursor\": \"QVFEdE1vdkVMV2xWa0M2a0lTZTNudHFfYy1mV1dzNld6UW1zV1dyYnZYeHNqNEtjXzJzZG9LS2RNZUJxekF6aEs4Q0RjcTUwZFhwczluRXdZODM5Vmlhdg==\", \"is_server_cursor_inverse\": true}")
      end
    end

    it 'returns an array of Comment objects' do
      VCR.use_cassette("hikerapi_comments_by_media_id") do
        response = subject.comments_by_media_id(media_id)

        expect(response).to be_a(Hash)
        expect(response[:comments].count).to eq(15)

        first_comment = response[:comments].first
        expect(first_comment).to be_a(ActiveInstagram::Comment)
        expect(first_comment.pk).to eq("18020723573300124")
        expect(first_comment.user.username).to eq("slr_khkhsr")
        expect(first_comment.text).to eq("❤️❤️❤️")
        expect(first_comment.created_at).to eq(Time.at(1710633443))
      end
    end

    it 'returns the next page of comments if available' do
      VCR.use_cassette("hikerapi_comments_by_media_id_next_page") do
        page_id = "{\"server_cursor\": \"QVFCRWdXM3lBSGs4amlBc2FzcmNfTEI0dXdIZHpESHJIMmdKallPX1NvMlU4aHJiUThJQzBLOUk0VkpWN2E3UmZKZTExUEFiU20td2hacWxQc1VTNUZrVQ==\", \"is_server_cursor_inverse\": true}"
        response = subject.comments_by_media_id(media_id, page_id)

        expect(response).to be_a(Hash)
        expect(response[:comments].count).to eq(15)

        first_comment = response[:comments].first
        expect(first_comment).to be_a(ActiveInstagram::Comment)
        expect(first_comment.pk).to eq("18069412414470254")
        expect(first_comment.user.username).to eq("the_y_centre")
        expect(first_comment.text).to eq("Wow! 🔥")
        expect(first_comment.created_at).to eq(Time.at(1708285437))
      end
    end

    it 'returns an empty array if no comments are found' do
      VCR.use_cassette("hikerapi_comments_by_media_id_no_comments") do
        response = subject.comments_by_media_id("3274706560752363530")

        expect(response).to be_an(Array)
        expect(response.count).to eq(0)
      end
    end

    it 'raises an error if the server returns an error' do
      VCR.use_cassette("hikerapi_comments_by_media_id") do
        response = instance_double("HTTParty::Response", code: 500, body: "Internal Server Error")
        allow(subject.class).to receive(:get).with(any_args).and_return(response)

        expect { subject.comments_by_media_id(media_id) }.to raise_error(ActiveInstagram::Drivers::ServerError)
      end
    end
  end
end
