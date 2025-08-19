# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateMediaCommentEmbeddingJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:media_comment) { double(MediaComment) }

    it 'calls generate_embedding! on the media comment' do
      allow(MediaComment).to receive(:find_by).with(id: 1).and_return(media_comment)
      expect(media_comment).to receive(:generate_embedding!)

      described_class.perform_now(1)
    end

    it 'does nothing if media comment is not found' do
      allow(MediaComment).to receive(:find_by).with(id: -1).and_return(nil)

      expect {
        described_class.perform_now(-1)
      }.not_to raise_error
    end
  end
end
