# frozen_string_literal: true

class RecalculateMediaPlanMetricJob < ApplicationJob
  queue_as :default

  def perform(*args)
    media_plan = MediaPlan.find_by(id: args[0])

    if media_plan.nil?
      Sentry.capture_message("RecalculateMediaPlanMetricJob: No media plan found with id: #{args[0]}")
      return
    end

    media_plan.recalculate_metrics
  end
end
