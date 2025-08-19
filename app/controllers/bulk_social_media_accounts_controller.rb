# frozen_string_literal: true

class BulkSocialMediaAccountsController < ApplicationController
  before_action :set_management, only: %i[new create]

  def new; end

  def create
    # Read file from .csv or .xlsx
    file = Roo::Spreadsheet.open(params[:file])

    # Parse file to arrays
    rows = file.sheet(0).parse

    # Loop through each row and assign to management
    imported_accounts = 0
    errors = []
    rows.each do |row|
      platform = row[1]
      username = row[2]
      social_media_account = SocialMediaAccount.find_by(platform: platform, username: username)

      if social_media_account.blank?
        errors << "No. #{row[0]} - #{platform} - #{username} not found"
        next
      end

      if @management.social_media_accounts.include?(social_media_account)
        errors << "No. #{row[0]} - #{platform} - #{username} already exists"
        next
      end

      @management.social_media_accounts << social_media_account
      imported_accounts += 1
    end

    # Set error and success message
    flash[:success] = success_message_for(imported_accounts, rows) if imported_accounts > 0
    flash[:danger] = errors if errors.any?

    redirect_to new_management_bulk_social_media_accounts_path
  end

  def download_template
    template_path = Rails.root.join('public', 'files', 'bulk_management_social_media_accounts_template.csv')
    send_file(template_path)
  end

  private
    def set_management
      @management = Management.find(params[:management_id])
    end

    def success_message_for(imported_accounts, rows)
      "Import completed: #{imported_accounts} accounts were successfully imported from #{rows.size} rows."
    end
end
