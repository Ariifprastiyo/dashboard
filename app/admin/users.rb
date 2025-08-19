# frozen_string_literal: true

ActiveAdmin.register User do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :deactivated_at, :organization_id
  #
  # or
  #

  permit_params :name, :email, :password, :password_confirmation, :organization_id, roles: []

  form do |f|
    # f.semantic_errors(*f.object.errors.keys)
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :password, required: false
      f.input :password_confirmation, required: false
      f.input :organization
    end

    f.inputs "Roles" do
      f.input :roles, as: :check_boxes, collection: Role.all.map { |r| [r.name, r.id] }, input_html: { multiple: true }
    end


    f.actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :created_at
    column :updated_at
    column :deactivated_at
    column "Roles" do |user|
      user.roles.map(&:name).join(', ')
    end
    actions
  end

  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end

      super do |format|
        if resource.valid?
          resource.roles.delete_all
          params[:user][:role_ids].reject(&:blank?).each do |role_id|
            role = Role.find(role_id)
            resource.add_role(role.name)
          end
        end
      end
    end
  end
end
