require 'rails_helper'

RSpec.describe TiktokMetricsCalculatorService do
  let(:user) { instance_double('ActiveTiktok::User') }
  let(:posts_collection) { instance_double('ActiveTiktok::MediaCollection', medias: posts) }
  let(:posts) do
    [
      instance_double('ActiveTiktok::Media',
        engagement_rate: 0.05,
        likes_count: 1000,
        comments_count: 100,
        shares_count: 50,
        impressions: 5000
      ),
      instance_double('ActiveTiktok::Media',
        engagement_rate: 0.07,
        likes_count: 2000,
        comments_count: 200,
        shares_count: 150,
        impressions: 7000
      ),
      instance_double('ActiveTiktok::Media',
        engagement_rate: 0.03,
        likes_count: 500,
        comments_count: 50,
        shares_count: 25,
        impressions: 3000
      )
    ]
  end

  subject(:calculator) { described_class.new(posts: posts_collection, user: user) }

  describe '#estimated_engagement_rate' do
    it 'calculates the average engagement rate' do
      expect(calculator.estimated_engagement_rate).to eq(0.05000000000000001) # (0.05 + 0.07 + 0.03) / 3
    end
  end

  describe '#estimated_likes_count' do
    it 'calculates the average likes count' do
      expect(calculator.estimated_likes_count).to eq(1166) # (1000 + 2000 + 500) / 3
    end
  end

  describe '#estimated_comments_count' do
    it 'calculates the average comments count' do
      expect(calculator.estimated_comments_count).to eq(116) # (100 + 200 + 50) / 3
    end
  end

  describe '#estimated_share_count' do
    it 'calculates the average share count' do
      expect(calculator.estimated_share_count).to eq(75) # (50 + 150 + 25) / 3
    end
  end

  describe '#estimated_impression' do
    it 'calculates the average impressions' do
      expect(calculator.estimated_impression).to eq(5000) # (5000 + 7000 + 3000) / 3
    end
  end

  describe '#estimated_reach' do
    it 'returns the same value as estimated_impression' do
      expect(calculator.estimated_reach).to eq(calculator.estimated_impression)
    end
  end

  context 'when posts collection is empty' do
    let(:posts) { [] }

    it 'raises an error when trying to calculate averages' do
      expect { calculator.estimated_engagement_rate }.to raise_error(ZeroDivisionError)
    end
  end
end
