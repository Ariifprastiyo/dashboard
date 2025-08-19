# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_locale
  after_action :record_page_view


  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def check_user_roles(*roles)
    if current_user.has_role?(:super_admin)
      return
    end

    unless current_user && roles.any? { |role| current_user.has_role?(role) }
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end

  def autheticate_admin_or_super_admin!
    return if current_user.has_role?(:admin) && current_user.organization.present?
    return if current_user.has_role?(:super_admin)

    redirect_to root_path
  end

  def check_super_admin_role
    redirect_to root_path unless current_user.has_role? :super_admin
  end


  def add_breadcrumb(label, url = nil, options = {})
    @breadcrumbs ||= []
    @breadcrumbs << { label: label, path: url, options: options }
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def record_not_found
    raise ActiveRecord::RecordNotFound, 'Record Not Found'
  end

  def user_not_authorized
    # redirect to back or root_path
    redirect_to request.referrer || root_path, alert: 'You are not authorized to perform this action.'
  end

  def admin_or_bd_required!
    user_not_authorized unless current_user.has_any_role? :admin, :bd
  end

  def version
    render json: { version: VERSION }
  end

  private
    def set_locale
      I18n.locale = params[:locale] || :id
    end

    def record_page_view
      return if !request.format.html? && !request.format.json?

      # Get user email if logged in
      user_email = current_user&.email

      RailsLocalAnalytics.record_request(
        request: request,
        custom_attributes: {
          site: {
            user_email: user_email
          },
          page: {},
        },
      )

      # clean 3 months old data
      TrackedRequestsByDayPage.where("day < ?", 3.months.ago).delete_all
      TrackedRequestsByDaySite.where("day < ?", 3.months.ago).delete_all
    end
end
