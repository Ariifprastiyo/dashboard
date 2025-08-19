require 'rails_helper'

RSpec.describe 'Users::Login', type: :feature do
  it 'returns agnostic error message' do
    visit new_user_session_path

    fill_in 'Email', with: 'hacker@email.com'
    fill_in 'Kata sandi', with: 'hacker123'
    click_button 'Login'
    expect(page).to have_content 'Email atau password yang anda masukkan salah.'
  end

  it 'redirect to dashboard when password was valid' do
    create(:user, email: 'hello@email.com', password: 'password123')
    visit new_user_session_path

    fill_in 'Email', with: 'hello@email.com'
    fill_in 'Kata sandi', with: 'password123'
    click_button 'Login'
    expect(page).to have_content 'Dashboard'
  end
end
