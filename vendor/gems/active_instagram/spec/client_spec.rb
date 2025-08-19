# frozen_string_literal: true

require "active_instagram/client"
require "active_instagram/drivers/hikerapi"

RSpec.describe ActiveInstagram::Client do
  let(:driver) { double("driver") }
  subject { described_class.new(driver: :hikerapi) }

  before do
    allow(ActiveInstagram::Drivers::Hikerapi).to receive(:new).and_return(driver)
  end

  describe "#profile_by_username" do
    let(:username) { "test_user" }
    let(:profile_data) { { username: "test_user" } }

    it "calls the driver to get the user profile" do
      expect(driver).to receive(:profile_by_username).with(username).and_return(profile_data)

      result = subject.profile_by_username(username)

      expect(result).to eq(profile_data)
    end
  end

  describe '#media_by_code' do
    let(:code) { "test_code" }
    let(:media_data) { { code: "test_code" } }

    it 'calls the driver to get the media' do
      expect(driver).to receive(:media_by_code).with(code).and_return(media_data)

      result = subject.media_by_code(code)

      expect(result).to eq(media_data)
    end
  end

  describe "#medias_by_user_id" do
    let(:user_id) { "test_user_id" }
    let(:medias_data) { [{ code: "test_code" }] }

    it "calls the driver to get the user medias" do
      expect(driver).to receive(:medias_by_user_id).with(user_id).and_return(medias_data)

      result = subject.medias_by_user_id(user_id)

      expect(result).to eq(medias_data)
    end
  end
end
