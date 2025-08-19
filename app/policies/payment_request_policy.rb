# frozen_string_literal: true

class PaymentRequestPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def index?
    user.has_any_role? :admin, :finance, :kol, :bd
  end

  def show?
    index?
  end

  def new?
    user.has_any_role? :admin, :finance, :kol, :bd
  end

  def create?
    user.has_any_role? :admin, :finance, :kol, :bd
  end

  def update?
    user.has_any_role? :admin, :finance
  end
end
