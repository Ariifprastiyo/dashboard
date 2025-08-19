require 'rails_helper'

RSpec.describe BulkInfluencerService, type: :service do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'bulk_influencers.xlsx') }
  let(:bulk_influencer) { create(:bulk_influencer, bulk_influencer_file: file_path) } # replace with your bulk_influencer factory or setup
  let(:row) { ['1234567890', 'Test Name', 'test_pic', '1234567890', 'male', 'adhytia', 'test_category', 'keluargaburw'] }
  let(:index) { 1 }
  let(:service) { BulkInfluencerService.new(bulk_influencer: bulk_influencer, row: row, index: index) }

  describe '#call' do
    context 'when the influencer data is valid' do
      it 'creates a new influencer' do
        expect { service.call }.to change(Influencer, :count).by(1)
      end

      it 'creates a new sosial media account' do
        expect { service.call }.to change(SocialMediaAccount, :count).by(2)
        expect(SocialMediaAccount.order('id desc').limit(2).pluck(:username)).to match_array(['adhytia', 'keluargaburw'])
      end

      it 'updates the current_row of the bulk_influencer' do
        service.call
        expect(bulk_influencer.reload.current_row).to eq(index + 2)
      end
    end

    context 'when the influencer data is invalid' do
      before do
        row[1] = nil # make the data invalid
      end

      it 'does not create a new influencer' do
        expect { service.call }.not_to change(Influencer, :count)
      end

      it 'creates an error message' do
        expect(service).to receive(:create_error_message).with(title: 'Influencer Data', message: ['Name tidak boleh kosong'])
        service.call
      end
    end
  end
end
