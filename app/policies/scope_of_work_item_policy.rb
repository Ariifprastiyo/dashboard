# frozen_string_literal: true

class ScopeOfWorkItemPolicy < ApplicationPolicy
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

  def new?
    create?
  end

  def create?
    user.has_any_role? :super_admin, :admin, :kol
  end

  def edit?
    update?
  end

  def update?
    user.has_any_role? :super_admin, :admin, :kol
  end
end
