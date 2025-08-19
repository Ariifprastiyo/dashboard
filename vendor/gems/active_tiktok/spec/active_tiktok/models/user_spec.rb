require 'spec_helper'

RSpec.describe ActiveTiktok::Models::User do
  describe '#initialize' do
    let(:user_attributes) do
      {
        id: '123',
        username: 'user123',
        full_name: 'User OneTwoThree',
        profile_picture: 'http://example.com/image.jpg',
        bio: 'This is a bio',
        website: 'http://example.com',
        media_count: 10,
        follows_count: 100,
        followed_by_count: 200
      }
    end

    subject(:user) { described_class.new(**user_attributes) }

    it 'initializes with correct attributes' do
      expect(user.id).to eq(user_attributes[:id])
      expect(user.username).to eq(user_attributes[:username])
      expect(user.full_name).to eq(user_attributes[:full_name])
      expect(user.profile_picture).to eq(user_attributes[:profile_picture])
      expect(user.bio).to eq(user_attributes[:bio])
      expect(user.website).to eq(user_attributes[:website])
      expect(user.media_count).to eq(user_attributes[:media_count])
      expect(user.follows_count).to eq(user_attributes[:follows_count])
      expect(user.followed_by_count).to eq(user_attributes[:followed_by_count])
    end
  end
end
