# frozen_string_literal: true

class CompetitorReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.has_role?(:super_admin)
        scope.all
      elsif user.has_role?(:spectator) && user.organization.present?
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

  def new?
    admin_or_bd? || user.has_role?(:super_admin)
  end

  def create?
    admin_or_bd? || user.has_role?(:super_admin)
  end

  def edit?
    admin_or_bd? || user.has_role?(:super_admin)
  end

  def update?
    admin_or_bd? || user.has_role?(:super_admin)
  end

  def destroy?
    user.has_role?(:admin) || user.has_role?(:super_admin)
  end
end
