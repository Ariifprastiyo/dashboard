require 'rails_helper'

RSpec.describe Influencer, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:social_media_accounts) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    # it { is_expected.to validate_presence_of(:pic_phone_number) }
    # it { is_expected.to validate_presence_of(:pic) }
  end

  describe '.personal_data_completed?' do
    it 'returns true if all personal data is filled' do
      influencer = create(:influencer, no_ktp: '123', no_npwp: 123, bank_code: 'aceh', account_number: '123', address: 'street')

      expect(influencer.personal_data_completed?).to be_truthy
    end

    it 'returns true when no_npwp is blank' do
      influencer = create(:influencer, no_ktp: '123', no_npwp: nil, bank_code: 'aceh', account_number: '123', address: 'street', have_npwp: false)

      expect(influencer.personal_data_completed?).to be_truthy
    end

    it 'returns false if any personal data is not filled' do
      influencer = create(:influencer, no_ktp: '123', no_npwp: 123, bank_code: 'aceh', account_number: '123', address: nil)

      expect(influencer.personal_data_completed?).to be_falsey
    end
  end
end
