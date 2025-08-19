RSpec.shared_examples "redirects to root path for non-super admin" do
  it "redirects to root path if user is a regular user" do
    sign_in create(:user)

    subject

    expect(response).to redirect_to(root_path)
  end

  it "redirects to root path even if user is admin" do
    sign_in create(:admin)

    subject

    expect(response).to redirect_to(root_path)
  end
end
