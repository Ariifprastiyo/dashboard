require 'rails_helper'

RSpec.describe OrganizationPolicy, type: :policy do
  subject { described_class.new(user, organization) }

  let(:organization) { Organization.new }

  context 'with non mediarumu admin' do
    let(:user) { User.new }

    it { is_expected.to permit_only_actions(%i[index show]) }
  end

  context 'with mediarumu admin' do
    let(:user) { User.new }

    before do
      user.add_role(:super_admin)
    end

    it { is_expected.to permit_all_actions }
  end
end
