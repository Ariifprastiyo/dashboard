require 'rails_helper'

RSpec.describe 'Users', type: :feature do
  let(:github) { create(:organization, name: 'GitHub') }
  let!(:user_github)  { create(:user, organization: github) }
  let!(:admin_github) { create(:admin, organization: github) }
  let(:apple) { create(:organization, name: 'Apple') }
  let!(:user_apple)  { create(:user, organization: apple) }
  let!(:super_admin) { create(:super_admin, organization: nil) }

  describe 'List users' do
    context 'when user is not an admin' do
      it 'redirects to root path' do
        sign_in user_github

        visit users_path

        expect(page).to have_current_path(root_path)
      end
    end

    context 'when user is an admin' do
      it 'shows the list of his organization\'s users' do
        sign_in admin_github

        visit users_path

        expect(page).to have_content(admin_github.name)
        expect(page).to have_content(user_github.name)
        expect(page).not_to have_content(user_apple.name)
        expect(page).not_to have_content(super_admin.name)
      end

      it 'redirects to root path when organization is not set' do
        sign_in create(:admin, organization: nil)

        visit users_path

        expect(page).to have_current_path(root_path)
      end
    end

    context 'when user is a super admin' do
      it 'shows the list of all users from all organizations' do
        sign_in super_admin

        visit users_path

        expect(page).to have_content(admin_github.name)
        expect(page).to have_content(user_github.name)
        expect(page).to have_content(user_apple.name)
        expect(page).to have_content(super_admin.name)
      end
    end
  end
end
