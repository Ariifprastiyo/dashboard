# frozen_string_literal: true

class BulkInfluencerPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index?
    user.has_any_role? :admin, :kol
  end

  def show?
    user.has_any_role? :admin, :kol
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def create?
    user.has_any_role? :admin, :kol
  end

  def update?
    user.has_any_role? :admin, :kol
  end

  def destroy?
    user.has_any_role? :admin
  end
end
