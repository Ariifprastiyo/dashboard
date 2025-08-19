# frozen_string_literal: true

module UsersHelper
  def delete_user_button(user)
    return if user == current_user
    return unless current_user.has_role? :admin

    button_to 'Delete', user_path(user), class: "btn btn-danger text-white", method: :delete, form: { data: { 'turbo-confirm': 'Are you sure?' } }
  end

  def deactivate_user_button(user)
    return if !user.active_for_authentication?
    return if user == current_user
    return unless current_user.has_role? :admin

    button_to 'Deactivate', deactivate_user_path(user), class: "btn btn-danger text-white", method: :put, form: { data: { 'turbo-confirm': 'Are you sure?' } }
  end

  def activate_user_button(user)
    return if user.active_for_authentication?
    return if user == current_user
    return unless current_user.has_role? :admin

    button_to 'Activate', activate_user_path(user), class: "btn btn-success text-white", method: :put, form: { data: { 'turbo-confirm': 'Are you sure?' } }
  end
end
