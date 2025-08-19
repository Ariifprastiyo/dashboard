# frozen_string_literal: true

module Campaigns
  class SocialMediaPublicationsController < ApplicationController
    before_action :authenticate_user!

    PER_PAGE = 50

    helper_method :index_for

    def show
      @campaign = policy_scope(Campaign).find_by(id: params[:id])
      @q = @campaign.social_media_publications
                                            .includes(:social_media_account)
                                            .ransack(params[:q])
      @social_media_publications = @q.result.order(created_at: :desc).page(params[:page]).per(PER_PAGE)
    end

    private
      def index_for(index)
        if params[:page].to_i == 0
          return index
        end

        last_number = (params[:page].to_i - 1) * PER_PAGE
        last_number + index
      end
  end
end
