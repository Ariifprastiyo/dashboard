require 'active_instagram/models/profile'

RSpec.describe ActiveInstagram::Profile do
  let(:user) { double('user') }
  let(:medias) { [] }

  subject { described_class.new(user: user, medias: medias) }

  describe '#initialize' do
    it 'sets the user and medias attributes' do
      expect(subject.user).to eq(user)
      expect(subject.medias).to eq(medias)
    end
  end
end
