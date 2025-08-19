# frozen_string_literal: true

class SocialMediaAccountPolicy < ApplicationPolicy
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

  def edit?
    update?
  end

  def create?
    user.has_any_role?(:admin, :kol) && user.organization.blank?
  end

  def update?
    user.has_any_role?(:admin, :kol) && user.organization.blank?
  end

  def destroy?
    user.has_any_role?(:admin) && user.organization.blank?
  end
end
