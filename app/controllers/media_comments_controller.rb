# frozen_string_literal: true

class MediaCommentsController < ApplicationController
  before_action :authenticate_user!

  helper_method :comment_no_for, :related_to_brand_options, :manual_reviewed_at_options

  def index
    @campaign = policy_scope(Campaign).find(params[:id])
    media_comments = MediaComment.joins(:social_media_publication)
                                  .where(social_media_publications: { campaign_id: @campaign.id })
                                  .order(created_at: :desc)
    @q = media_comments.order(comment_at: :desc).ransack(params[:q])
    @comments = @q.result.page(params[:page]).per(100)

    add_breadcrumb @campaign.name, campaign_path(@campaign)
  end

  def update
    @number = params[:number]
    @media_comment = MediaComment.find_by(id: params[:media_comment_id])
    @media_comment.manually_update_related_to_brand(params[:related_to_brand])
    respond_to do |format|
      format.turbo_stream
    end
  end

  private
    def comment_no_for(index)
      if params[:page].to_i == 0
        return index
      end

      last_number = (params[:page].to_i - 1) * 100
      last_number + index
    end

    def manual_reviewed_at_options
      {
        'All' => nil,
        'Manual Reviewed' => false,
        'Not Reviewed' => true
      }
    end

    def related_to_brand_options
      {
        'All' => nil,
        'Related' => true,
        'Unrelated' => false
      }
    end
end
