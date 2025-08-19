require 'rails_helper'

RSpec.describe "/organizations", type: :request do
  let(:super_admin) { create(:super_admin) }

  describe "GET /index" do
    subject { get organizations_path }

    include_examples "redirects to root path for non-super admin"

    it "renders a successful response" do
      sign_in super_admin

      get organizations_path
      expect(response).to be_successful
    end

    it "lists all organizations" do
      sign_in super_admin
      2.times { |n| create(:organization, name: "Organization #{n}", description: "Description #{n}") }

      get organizations_path

      expect(response.body).to include("Organization 0")
      expect(response.body).to include("Description 0")
      expect(response.body).to include("Organization 1")
      expect(response.body).to include("Description 1")
    end
  end

  describe "GET /new" do
    subject { get new_organization_path }

    include_examples "redirects to root path for non-super admin"

    it "renders a successful response" do
      sign_in super_admin

      get new_organization_path
      expect(response).to be_successful
    end

    it "renders a form to create a new organization" do
      sign_in super_admin

      get new_organization_path

      expect(response.body).to include("New Organization")
      expect(response.body).to include("Name")
      expect(response.body).to include("Description")
    end
  end

  describe "POST /create" do
    subject { post organizations_path, params: { organization: { name: "Organization", description: "Description" } } }

    include_examples "redirects to root path for non-super admin"

    it "creates a new Organization" do
      sign_in super_admin

      expect {
        subject
      }.to change(Organization, :count).by(1)

      expect(response).to redirect_to(organizations_path)
      expect(flash[:notice]).to eq("Organization was successfully created.")
    end

    it "displays an error message if organization creation fails" do
      sign_in super_admin

      # Invalid attributes for organization creation
      invalid_attributes = { name: "", description: "" }

      expect {
        post organizations_path, params: { organization: invalid_attributes }
      }.not_to change(Organization, :count)

      expect(response.body).to include("Name tidak boleh kosong")
    end
  end

  describe "GET /edit" do
    let(:organization) { create(:organization) }
    subject { get edit_organization_path(organization) }

    include_examples "redirects to root path for non-super admin"

    it "renders a successful response" do
      sign_in super_admin

      get edit_organization_path(organization)

      expect(response).to be_successful
    end

    it "renders a form to edit the organization" do
      sign_in super_admin

      get edit_organization_path(organization)

      expect(response.body).to include("Editing #{organization.name}")
      expect(response.body).to include("Name")
      expect(response.body).to include("Description")
    end
  end

  describe "PATCH /update" do
    let(:organization) { create(:organization, name: 'Organization', description: 'Description') }
    subject { patch organization_path(organization), params: { organization: { name: "New Organization", description: "New Description" } } }

    include_examples "redirects to root path for non-super admin"

    it "updates the organization" do
      sign_in super_admin

      subject

      organization.reload

      expect(organization.name).to eq("New Organization")
      expect(organization.description).to eq("New Description")
      expect(response).to redirect_to(organizations_path)
      expect(flash[:notice]).to eq("Organization was successfully updated.")
    end

    it "displays an error message if organization update fails" do
      sign_in super_admin

      # Invalid attributes for organization update
      invalid_attributes = { name: "", description: "" }

      patch organization_path(organization), params: { organization: invalid_attributes }

      expect(response.body).to include("Name tidak boleh kosong")
    end
  end
end
