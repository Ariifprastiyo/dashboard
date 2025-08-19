require 'active_instagram/models/media'

RSpec.describe ActiveInstagram::Media do
  let(:id) { 1 }
  let(:pk) { 2 }
  let(:shortcode) { 'abc123' }
  let(:taken_at) { Time.now }
  let(:display_url) { 'https://example.com/image.jpg' }
  let(:thumbnail_url) { 'https://example.com/thumbnail.jpg' }
  let(:video_url) { 'https://example.com/video.mp4' }
  let(:product_type) { 'photo' }
  let(:title) { 'Example Media' }
  let(:video_duration) { 60 }
  let(:video_view_count) { 100 }
  let(:caption) { 'This is an example caption' }
  let(:comments_count) { 5 }
  let(:comments_disabled) { false }
  let(:likes_count) { 10 }
  let(:username) { 'example_username' }

  subject(:media) do
    described_class.new(
      id: id,
      pk: pk,
      shortcode: shortcode,
      taken_at: taken_at,
      display_url: display_url,
      thumbnail_url: thumbnail_url,
      video_url: video_url,
      product_type: product_type,
      title: title,
      video_duration: video_duration,
      video_view_count: video_view_count,
      caption: caption,
      comments_count: comments_count,
      comments_disabled: comments_disabled,
      likes_count: likes_count,
      username: username
    )
  end

  describe '#id' do
    it 'returns the media id' do
      expect(media.id).to eq(id)
    end
  end

  describe '#shortcode' do
    it 'returns the media shortcode' do
      expect(media.shortcode).to eq(shortcode)
    end
  end

  describe '#taken_at' do
    it 'returns the media taken_at time' do
      expect(media.taken_at).to eq(taken_at)
    end
  end

  describe '#display_url' do
    it 'returns the media display URL' do
      expect(media.display_url).to eq(display_url)
    end
  end

  # Add more tests for other attributes...
end
