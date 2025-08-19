require 'active_instagram/models/comment'

RSpec.describe ActiveInstagram::Comment do
  let(:pk) { 1 }
  let(:text) { 'This is a comment' }
  let(:created_at) { Time.now }
  let(:user) { double('User') }

  subject(:comment) do
    described_class.new(pk: pk, text: text, created_at: created_at, user: user)
  end

  describe '#pk' do
    it 'returns the comment id' do
      expect(comment.pk).to eq(pk)
    end
  end

  describe '#text' do
    it 'returns the comment text' do
      expect(comment.text).to eq(text)
    end
  end

  describe '#created_time' do
    it 'returns the comment created time' do
      expect(comment.created_at).to eq(created_at)
    end
  end

  describe '#user' do
    it 'returns the comment user' do
      expect(comment.user).to eq(user)
    end
  end
end
