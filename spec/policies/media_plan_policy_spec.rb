require 'rails_helper'

RSpec.describe MediaPlanPolicy, type: :policy do
  subject { MediaPlanPolicy::Scope.new(user, MediaPlan).resolve }

  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  # Users
  let!(:user_in_org) { create(:user, name: 'user_in_org', organization: organization) }
  let!(:admin_in_org) { create(:user, name: 'user_in_org', organization: organization) }
  let!(:user_in_other_org) { create(:user, name: 'user_in_other_org', organization: other_organization) }
  let!(:super_admin) { create(:user, name: 'super_admin', organization: nil) }
  let!(:admin_no_org) { create(:user, name: 'admin', organization: nil) }

  # campaigns
  let!(:campaign_in_org) { create(:campaign, organization: organization) }
  let!(:campaign_in_other_org) { create(:campaign, organization: other_organization) }

  # Brands
  let!(:mediaplan_in_org) { create(:media_plan, campaign: campaign_in_org) }
  let!(:mediaplan_in_other_org) { create(:media_plan, campaign: campaign_in_other_org) }

  before do
    super_admin.add_role(:super_admin)
    admin_no_org.add_role(:admin)
    admin_in_org.add_role(:admin)
  end

  permissions ".scope" do
    context 'when the user is a super_admin' do
      let(:user) { super_admin }

      it 'includes all users' do
        expect(subject).to contain_exactly(mediaplan_in_org, mediaplan_in_other_org)
      end
    end

    context 'when the user is an admin' do
      let(:user) { admin_in_org }

      it 'includes mediaplans from their organization' do
        expect(subject).to contain_exactly(mediaplan_in_org)
      end

      it 'returns an empty scope when the user has no organization' do
        admin_in_org.update(organization: nil)

        expect(subject).to contain_exactly()
      end
    end

    context 'when the user has no special roles' do
      let(:user) { user_in_org }

      it 'shows only the mediaplans from the user organization' do
        expect(subject).to contain_exactly(mediaplan_in_org)
      end
    end
  end

  permissions :show? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :destroy? do
    # only admin can destroy
    context 'when the user is a admin' do
      subject { described_class.new(user, mediaplan_in_org) }
      let(:user) { admin_in_org }

      it { is_expected.to permit_action(:destroy) }
    end

    context 'when the user is a admin' do
      subject { described_class.new(user, mediaplan_in_org) }
      let(:user) { user_in_org }

      it { is_expected.to forbid_action(:destroy) }
    end
  end

  permissions :export? do
    context 'when the user is a admin' do
      subject { described_class.new(user, mediaplan_in_org) }
      let(:user) { admin_in_org }

      it { is_expected.to permit_action(:export) }
    end

    context 'when the user is a admin' do
      subject { described_class.new(user, mediaplan_in_org) }
      let(:user) { user_in_org }

      it { is_expected.to forbid_action(:export) }
    end
  end
end
