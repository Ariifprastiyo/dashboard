# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.has_role?(:super_admin)
  end

  def new?
    user.has_role?(:super_admin)
  end

  def update?
    user.has_role?(:super_admin)
  end

  def edit?
    user.has_role?(:super_admin)
  end

  def destroy?
    user.has_role?(:super_admin)
  end
end
