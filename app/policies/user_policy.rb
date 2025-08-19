# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # MediaRumu admin should be super admin
    def resolve
      if user.has_role?(:super_admin)
        scope.all
      elsif user.has_role?(:admin) && user.organization
        scope.where(organization: user.organization)
      else
        scope.none
      end
    end
  end
end
