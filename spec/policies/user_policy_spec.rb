require 'rails_helper'

RSpec.describe UserPolicy do
  subject { UserPolicy::Scope.new(user, User).resolve }

  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  # Users
  let!(:user_in_org) { create(:user, name: 'user_in_org', organization: organization) }
  let!(:user_in_other_org) { create(:user, name: 'user_in_other_org', organization: other_organization) }
  let!(:super_admin) { create(:user, name: 'super_admin', organization: nil) }
  let!(:admin) { create(:user, name: 'admin', organization: nil) }

  before do
    super_admin.add_role(:super_admin)
    admin.add_role(:admin)
  end

  describe 'Scope' do
    context 'when the user is a super_admin' do
      let(:user) { super_admin }

      it 'includes all users' do
        expect(subject).to contain_exactly(user_in_org, user_in_other_org, super_admin, admin)
      end
    end

    context 'when the user is an admin' do
      let(:user) { admin }

      it 'includes users from their organization' do
        admin.update(organization: organization)

        expect(subject).to contain_exactly(admin, user_in_org)
      end

      it 'returns an empty scope when the user has no organization' do
        expect(subject).to contain_exactly()
      end
    end

    context 'when the user has no special roles' do
      let(:user) { create(:user) }

      it 'is empty' do
        expect(subject).to be_empty
      end
    end
  end
end
