require 'active_instagram/models/user'

RSpec.describe ActiveInstagram::User do
  let(:user) do
    ActiveInstagram::User.new(
      id: 1,
      username: 'john_doe',
      full_name: 'John Doe',
      profile_picture: 'https://example.com/profile.jpg',
      bio: 'Software Developer',
      website: 'https://example.com',
      media_count: 10,
      follows_count: 100,
      followed_by_count: 200
    )
  end

  describe '#initialize' do
    it 'sets the correct attributes' do
      expect(user.id).to eq(1)
      expect(user.username).to eq('john_doe')
      expect(user.full_name).to eq('John Doe')
      expect(user.profile_picture).to eq('https://example.com/profile.jpg')
      expect(user.bio).to eq('Software Developer')
      expect(user.website).to eq('https://example.com')
      expect(user.media_count).to eq(10)
      expect(user.follows_count).to eq(100)
      expect(user.followed_by_count).to eq(200)
    end
  end
end
