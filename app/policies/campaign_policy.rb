# frozen_string_literal: true

class CampaignPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.has_role?(:super_admin)
        scope.all
      elsif user.organization.present?
        scope.where(organization: user.organization)
      else
        scope.none
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    # if user.has_role?(:super_admin)
    #   true
    # elsif user.organization.present?
    #   admin_or_bd? && record.brand.organization == user.organization
    # else
    #   admin_or_bd?
    # end
    (admin_or_bd? || user.has_role?(:super_admin)) # && record.brand.organization == user.organization
  end

  def new?
    create?
  end

  def update?
    admin_or_bd? || user.has_role?(:super_admin)
  end

  def edit?
    update?
  end

  def utility?
    user.has_any_role?(:super_admin, :admin, :bd, :kol)
  end

  def destroy?
    user.has_role?(:admin) || user.has_role?(:super_admin)
  end

  def timeline?
    true
  end

  def export_word_cloud?
    true
  end
end
