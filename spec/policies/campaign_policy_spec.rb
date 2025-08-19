require 'rails_helper'

RSpec.describe CampaignPolicy, type: :policy do
  subject { CampaignPolicy::Scope.new(user, Campaign).resolve }

  # Organizations
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  # Users
  let!(:user_in_org) { create(:user, name: 'user_in_org', organization: organization) }
  let!(:admin_in_org) { create(:user, name: 'user_in_org', organization: organization) }
  let!(:user_in_other_org) { create(:user, name: 'user_in_other_org', organization: other_organization) }
  let!(:super_admin) { create(:user, name: 'super_admin', organization: nil) }
  let!(:admin_no_org) { create(:user, name: 'admin', organization: nil) }

  # Campaigns
  let!(:campaign_in_org) { create(:campaign, organization: organization) }
  let!(:campaign_in_other_org) { create(:campaign, organization: other_organization) }

  before do
    super_admin.add_role(:super_admin)
    admin_no_org.add_role(:admin)
    admin_in_org.add_role(:admin)
  end

  permissions ".scope" do
    context 'when the user is a super_admin' do
      let(:user) { super_admin }

      it 'includes all campaigns' do
        expect(subject).to contain_exactly(campaign_in_org, campaign_in_other_org)
      end
    end

    context 'when the user is an admin' do
      let(:user) { admin_in_org }

      it 'includes users from their organization' do
        expect(subject).to contain_exactly(campaign_in_org)
      end

      it 'returns an empty scope when the user has no organization' do
        admin_in_org.update(organization: nil)

        expect(subject).to contain_exactly()
      end
    end

    context 'when the user has no special roles' do
      let(:user) { user_in_org }

      it 'shows only the brands from the user organization' do
        expect(subject).to contain_exactly(campaign_in_org)
      end
    end
  end

  context 'when the user is a super_admin' do
    let(:user) { super_admin }
    subject { described_class.new(user, campaign_in_org) }

    it { is_expected.to permit_all_actions }
  end

  context 'when the user is an admin' do
    let(:user) { admin_in_org }
    subject { described_class.new(user, campaign_in_org) }

    it { is_expected.to permit_all_actions }
  end

  context 'when the user is an org user' do
    let(:user) { user_in_org }
    subject { described_class.new(user, campaign_in_org) }

    it { is_expected.to permit_only_actions(%i[index show timeline export_word_cloud]) }
  end
end
