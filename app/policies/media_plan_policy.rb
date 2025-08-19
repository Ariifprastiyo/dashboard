# frozen_string_literal: true

class MediaPlanPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.has_role?(:super_admin)
        scope.all
      else
        scope.joins(campaign: :organization).where(organizations: { id: user.organization_id })
      end
    end
  end

  def destroy?
    admin_or_bd?
  end

  def export?
    admin_or_bd?
  end
end
