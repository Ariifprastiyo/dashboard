# frozen_string_literal: true

class ManagementPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def new?
    admin_or_bd?
  end

  def edit?
    admin_or_bd?
  end

  def create?
    admin_or_bd?
  end

  def update?
    admin_or_bd?
  end

  def destroy?
    user.has_role?(:admin)
  end
end
