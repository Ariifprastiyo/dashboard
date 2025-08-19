require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it { is_expected.to belong_to(:organization).optional }

  describe 'ROLES' do
    it 'contains the correct roles' do
      expect(User::ROLES).to contain_exactly(:admin, :finance, :kol, :bd, :spectator, :super_admin)
    end
  end

  describe '#deactivate!' do
    it 'deactivates a user' do
      user.deactivate!

      expect(user.deactivated_at).to be_present
      expect(user.active_for_authentication?).to be_falsey
    end
  end

  describe '#activate!' do
    it 'activates a user' do
      user.activate!

      expect(user.deactivated_at).to be_nil
      expect(user.active_for_authentication?).to be_truthy
    end
  end

  describe 'super admin' do
    it 'can be if not a member of any organization' do
      user.add_role(:super_admin)

      expect(user.has_role?(:super_admin)).to be_truthy
    end

    it 'cannot be if a member of an organization' do
      user.organization = build(:organization)

      user.add_role(:super_admin)

      expect(user.has_role?(:super_admin)).to be_falsey
    end
  end
end
