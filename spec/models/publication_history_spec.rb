require 'rails_helper'

RSpec.describe PublicationHistory, type: :model do
  describe '.create_from_social_media_publication' do
    let(:brand) { create(:brand) }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }

    describe '#total_engagement' do
      it 'returns expected result' do
        publication = build(:publication_history, likes_count: 10, comments_count: 10, share_count: 10, saves_count: 10)
        expect(publication.total_engagement).to eq(40)
      end
    end

    it 'create a new publication history' do
      account = create(:social_media_account, :instagram, username: 'pewdiepie')
      scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)

      publication = create(:social_media_publication, :instagram, url: 'CmTF9nJp18C', campaign: campaign, scope_of_work: scope_of_work)

      publication_history = described_class.create_from_social_media_publication(publication)

      expect(publication_history).to have_attributes(
        likes_count: publication.likes_count,
        comments_count: publication.comments_count,
        impressions: publication.impressions,
        reach: publication.reach,
        engagement_rate: publication.engagement_rate,
        share_count: publication.share_count,
        campaign_id: publication.campaign_id,
        platform: publication.platform,
        social_media_account_size: publication.social_media_account.size,
        social_media_account_id: publication.social_media_account_id,
        related_media_comments_count: publication.related_media_comments_count
      )
    end
  end
end
