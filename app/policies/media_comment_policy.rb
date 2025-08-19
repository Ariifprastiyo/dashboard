# frozen_string_literal: true

class MediaCommentPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def edit?
    update?
  end

  def update?
    user.has_any_role? :admin, :kol
  end
end
