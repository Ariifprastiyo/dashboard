require 'rails_helper'

RSpec.describe "ScopeOfWorks", type: :request do
  include CompleteBasicSetup

  before do
    admin = create(:admin)
    sign_in admin
  end

  let(:kol_mega) { create(:social_media_account, :instagram_mega_manual) }
  let(:kol_with_management) { create(:social_media_account, :instagram_micro_manual) }

  let(:management) { create(:management) }

  describe "POST #create" do
    it 'renders a successful response' do
      expect do
        post media_plan_scope_of_works_path(@media_plan), params: { media_plan_id: @media_plan.id, social_media_account_id: kol_mega.id }
      end.to change(ScopeOfWork, :count).by(1)

      expect(response).to be_redirect
    end

    it 'populate required data' do
      post media_plan_scope_of_works_path(@media_plan), params: { media_plan_id: @media_plan.id, social_media_account_id: kol_mega.id }

      expect(ScopeOfWorkItem.count).to eq(9)
    end

    it 'handle management' do
      management.social_media_accounts << kol_with_management

      params = { "q" => { "managements_id_eq" => management.id } }

      # make sure session for management_id is set, we need to visit new_media_plan_scope_of_work_path with params
      get new_media_plan_scope_of_work_path(@media_plan, params)

      post media_plan_scope_of_works_path(@media_plan), params: { media_plan_id: @media_plan.id, social_media_account_id: kol_with_management.id }

      expect(ScopeOfWork.last.management_id).to eq(management.id)
    end
  end
end
