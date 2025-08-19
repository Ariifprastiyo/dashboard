# frozen_string_literal: true

RSpec.describe ActiveInstagram do
  it "has a version number" do
    expect(ActiveInstagram::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields the configuration object" do
      ActiveInstagram.configure do |config|
        expect(config).to be_an_instance_of(ActiveInstagram::Configuration)
      end
    end
  end

  let(:username) { "test_user" }
  let(:client) { double("client") }
  let(:profile_data) { { username: "test_user" } }

  describe ".profile_by_username" do
    it "delegates to the client" do
      allow(ActiveInstagram).to receive(:client).and_return(client)
      expect(client).to receive(:profile_by_username).with(username).and_return(profile_data)

      result = ActiveInstagram.profile_by_username(username)

      expect(result).to eq(profile_data)
    end
  end

  describe ".media_by_code" do
    it "delegates to the client" do
      code = "test_code"
      media_data = { code: "test_code" }

      allow(ActiveInstagram).to receive(:client).and_return(client)
      expect(client).to receive(:media_by_code).with(code).and_return(media_data)

      result = ActiveInstagram.media_by_code(code)

      expect(result).to eq(media_data)
    end
  end

  describe ".medias_by_user_id" do
    it "delegates to the client" do
      user_id = "test_user_id"
      medias_data = [{ code: "test_code" }]

      allow(ActiveInstagram).to receive(:client).and_return(client)
      expect(client).to receive(:medias_by_user_id).with(user_id).and_return(medias_data)

      result = ActiveInstagram.medias_by_user_id(user_id)

      expect(result).to eq(medias_data)
    end
  end

  describe '.comments_by_media_id' do
    it 'delegates to the client' do
      media_id = "test_media_id"
      page_id = "test_page_id"

      allow(ActiveInstagram).to receive(:client).and_return(client)
      expect(client).to receive(:comments_by_media_id).with(media_id, page_id).and_return([])

      described_class.comments_by_media_id(media_id, page_id)
    end
  end
end
