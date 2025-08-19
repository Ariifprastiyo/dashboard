# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    start_date = params.fetch(:start_date, Date.current).to_date.beginning_of_month
    end_date = start_date.end_of_month

    @scheduled_posts = ScopeOfWorkItem
      .scheduled_between(start_date.beginning_of_day, end_date.end_of_day)
      .joins(:social_media_account)
      .group('DATE(scope_of_work_items.scheduled_at)', 'social_media_accounts.size')
      .count
      .transform_keys { |(date, size)| [date.to_date, size] }
      .group_by { |(date, _), _| date }
      .transform_values { |items| items.to_h { |(_, size), count| [size, count] } }

    @posted_posts = ScopeOfWorkItem
      .posted_between(start_date.beginning_of_day, end_date.end_of_day)
      .joins(:social_media_account)
      .group('DATE(scope_of_work_items.posted_at)', 'social_media_accounts.size')
      .count
      .transform_keys { |(date, size)| [date.to_date, size] }
      .group_by { |(date, _), _| date }
      .transform_values { |items| items.to_h { |(_, size), count| [size, count] } }
  end
end
