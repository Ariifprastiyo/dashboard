require 'rails_helper'

RSpec.describe PaymentRequest, type: :model do
  it { should belong_to(:beneficiary) }
  it { should belong_to(:campaign) }
  it { should belong_to(:payer).class_name('User').optional }
  it { should belong_to(:requestor).class_name('User') }

  it { should define_enum_for(:status)
                .with_values({ pending: 0, paid: 1, processed: 2, rejected: 3 }) }

  it { should have_one_attached(:invoice) }
  it { should have_one_attached(:payment_proof) }

  # validations
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).is_greater_than(0) }
  it { should validate_presence_of(:due_date) }
  it { should validate_presence_of(:invoice) }

  # validate tax_invoice_number if ppn is true
  # it { should validate_presence_of(:tax_invoice_number).if(:ppn?) }

  let!(:campaign) { create(:campaign) }
  let!(:media_plan) { create(:media_plan, :empty, campaign: campaign) }

  describe 'status' do
    let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
    let!(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }
    let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

    it 'should have default status of pending' do
      payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)

      expect(payment_request.status).to eq('pending')
    end
  end

  describe 'campaign' do
    let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
    let!(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }
    let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

    it 'should have campaign with selected media plan' do
      payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)

      expect(payment_request).not_to be_valid
      expect(payment_request.errors).to include(:campaign)
    end
  end


  describe 'benficiary' do
    let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
    let!(:unassigned_social_media_account) { create(:social_media_account, :instagram_macro_manual) }
    let!(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }
    let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

    before do
      campaign.update(selected_media_plan: media_plan)
    end

    it 'should not allow social media account that is not in scope of works' do
      payment_request = build(:payment_request, campaign: campaign, beneficiary: unassigned_social_media_account, amount: 10_000_000)

      expect(payment_request).not_to be_valid
      expect(payment_request.errors).to include(:beneficiary)
    end

    it 'should not allow social media account to be the beneficiary if its assigned to the management' do
      management = create(:management)
      sow.update(management: management)

      payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)

      expect(payment_request).not_to be_valid
      expect(payment_request.errors).to include(:beneficiary)
    end

    it 'should not allow management that is not assigned to scope of works' do
      management = create(:management)

      payment_request = build(:payment_request, campaign: campaign, beneficiary: management, amount: 10_000_000)

      expect(payment_request).not_to be_valid
      expect(payment_request.errors).to include(:beneficiary)
    end

    it 'should allow social media account that is in scope of works' do
      management = create(:management)
      sow.update(management: management)

      social_media_account2 = create(:social_media_account, :instagram_mega_manual)
      sow2 = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account2)
      create(:scope_of_work_item, scope_of_work: sow2, quantity: 1, price: 10_000_000, subtotal: 10_000_000)

      payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account2, amount: 10_000_000)

      expect(payment_request).to be_valid
    end
  end

  describe 'total amount' do
    before do
      campaign.update(selected_media_plan: media_plan)
    end

    context 'beneficiary is a social media account' do
      let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
      let!(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }
      let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

      it 'should allow if the total amount is less than or equal to the total amount of the scope of work' do
        payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)

        expect(payment_request).to be_valid
      end

      it 'should allow if the total amount is less than or equal to the total amount of the scope of work minus the total of payment requested' do
        # Rejected payment request should be ignored
        create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 5_000_000, status: :rejected)

        create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 5_000_000)

        payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 5_000_000)

        expect(payment_request).to be_valid
      end

      it 'should not exceed the total amount of the scope of work' do
        payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 14_000_000)

        expect(payment_request).to_not be_valid
      end

      it 'should not exceed the total amount of the scope of work minus the total of payment requested' do
        create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 5_000_000)

        payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)

        expect(payment_request).to_not be_valid
      end

      it 'should have scope of work item' do
        sow_item.destroy

        payment_request = build(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)

        expect(payment_request).to_not be_valid
      end
    end

    context 'beneficiary is a Management' do
      let(:management) { create(:management) }
      let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }

      before do
        # assign social media account to management
        management.social_media_accounts << social_media_account

        # not using let! because we need to make sure that the sow is marked with management_id
        @sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account, management_id: management.id)
        @sow_item = create(:scope_of_work_item, scope_of_work: @sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
      end

      it 'should allow if the total amount is less than or equal to the total amount of the scope of work' do
        payment_request = build(:payment_request, campaign: campaign, beneficiary: management, amount: 10_000_000)

        expect(payment_request).to be_valid
      end

      it 'should not exceed the total amount of the scope of work' do
        payment_request = build(:payment_request, campaign: campaign, beneficiary: management, amount: 11_000_000)

        expect(payment_request).to_not be_valid
      end
    end
  end

  describe 'tax' do
    let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
    let!(:unassigned_social_media_account) { create(:social_media_account, :instagram_macro_manual) }
    let!(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }
    let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

    before do
      campaign.update(selected_media_plan: media_plan)
    end

    describe 'total_ppn' do
      it 'return 0 if dont have ppn' do
        payment_request = create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, ppn: false)

        expect(payment_request.total_ppn).to eq 0
      end

      it 'return 11% of amount if have ppn' do
        payment_request = create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, ppn: true)

        expect(payment_request.total_ppn).to eq 1_100_000
      end
    end

    describe 'total_pph' do
      let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
      let!(:unassigned_social_media_account) { create(:social_media_account, :instagram_macro_manual) }
      let!(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }
      let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

      before do
        campaign.update(selected_media_plan: media_plan)
      end

      it 'return 0 if pph is gross_up' do
        payment_request = create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, pph_option: 'gross_up', total_pph: 1_000_000)

        expect(payment_request.total_pph).to eq 0
      end

      it 'return total_pph if pph is nett' do
        payment_request = create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, pph_option: 'nett', total_pph: 1_000_000)

        expect(payment_request.total_pph).to eq 1_000_000
      end
    end

    describe 'total_payment' do
      it 'consider ppn and pph' do
        payment_request = create(:payment_request, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, ppn: true, pph_option: 'nett', total_pph: 1_000_000)

        total = 10_000_000 + 1_100_000 - 1_000_000

        expect(payment_request.total_payment).to eq total
      end
    end
  end
end
