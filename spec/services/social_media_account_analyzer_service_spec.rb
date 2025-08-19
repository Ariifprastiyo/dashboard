require 'rails_helper'

RSpec.describe String do
  subject { described_class.new }

  it 'should create recents social media publications'
  it 'should fetch comments for each publication'
  it 'should provide a conclusion about the account'

  context "social_media_account is not present in database" do
    it "should create a new influencer and social_media_account"
  end
end
