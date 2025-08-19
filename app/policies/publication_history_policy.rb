# frozen_string_literal: true

class PublicationHistoryPolicy < ApplicationPolicy
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

  def edit?
    user.has_any_role? :admin, :kol
  end

  def update?
    user.has_any_role? :admin, :kol
  end

  def new?
    user.has_any_role? :admin, :kol
  end

  def create?
    user.has_any_role? :admin, :kol
  end

  def destroy?
    user.has_role? :admin
  end
end
