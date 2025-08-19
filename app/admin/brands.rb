# frozen_string_literal: true

ActiveAdmin.register Brand do
  permit_params :name, :description, :instagram, :tiktok, :discarded_at, :organization_id

  controller do
    def scoped_collection
      super.includes(:organization, :campaigns, :selected_media_plans)
    end
  end

  filter :name
  filter :description
  filter :instagram
  filter :tiktok
  filter :organization
  filter :campaigns
  filter :selected_media_plans

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :instagram
      f.input :tiktok
      f.input :organization
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :instagram
    column :tiktok
    column :organization
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :instagram
      row :tiktok
      row :organization
      row :created_at
      row :updated_at
    end
  end
end
