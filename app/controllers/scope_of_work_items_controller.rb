# frozen_string_literal: true

class ScopeOfWorkItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_scope_of_work
  before_action :check_campaign_ownership

  def index
    @scope_of_work_items = @scope_of_work.scope_of_work_items
    authorize @scope_of_work_items

    @social_media_account = @scope_of_work.social_media_account

    campaign = @scope_of_work.campaign
    add_breadcrumb campaign.name, campaign_path(campaign)
  end

  def edit
    @scope_of_work_item = ScopeOfWorkItem.find(params[:id])
    authorize @scope_of_work_item

    @social_media_account = @scope_of_work.social_media_account
    @campaign = @scope_of_work_item.campaign
    @social_media_publication = @scope_of_work_item.social_media_publication || @scope_of_work_item.build_social_media_publication
    @publication_histories = @social_media_publication.publication_histories.order(created_at: :desc)

    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb 'Scope of work', scope_of_work_scope_of_work_items_path(@scope_of_work)
  end

  def update
    @scope_of_work_item = ScopeOfWorkItem.find(params[:id])
    @social_media_publication = @scope_of_work_item.social_media_publication
    @campaign = @scope_of_work_item.campaign


    if @scope_of_work_item.update(scope_of_work_item_params)
      redirect_to({ action: :edit }, notice: 'Scope of work item was successfully updated.')
    else
      redirect_to({ action: :edit }, alert: 'Scope of work item was not updated.')
    end
  end


  private
    def scope_of_work_item_params
      params.require(:scope_of_work_item).permit(:scheduled_at, :posted_at)
    end

    def find_scope_of_work
      @scope_of_work = ScopeOfWork.find(params[:scope_of_work_id])
    end

    # check if the current organization owns the campaign
    def check_campaign_ownership
      policy_scope(Campaign).find(@scope_of_work.campaign.id)
    end
end
