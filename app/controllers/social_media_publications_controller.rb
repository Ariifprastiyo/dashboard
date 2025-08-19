# frozen_string_literal: true

class SocialMediaPublicationsController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveInstagram::Drivers::ProfileNotFoundError, with: :instagram_profile_not_found
  rescue_from ActiveInstagram::Drivers::MediaNotFoundError, with: :instagram_profile_not_found
  rescue_from ActiveInstagram::Drivers::ServerError, with: :server_error

  def create
    @scope_of_work_item = ScopeOfWorkItem.find(params[:scope_of_work_item_id])
    @scope_of_work = @scope_of_work_item.scope_of_work
    @campaign = @scope_of_work_item.campaign
    @social_media_account = @scope_of_work.social_media_account


    parameters = social_media_publication_params.merge({  scope_of_work_item_id: @scope_of_work_item.id,
                                                          social_media_account_id: @social_media_account.id,
                                                          campaign_id: @campaign.id,
                                                          scope_of_work_id: @scope_of_work_item.scope_of_work_id,
                                                          platform: @campaign.platform
                                                        })

    @social_media_publication = SocialMediaPublication.new(parameters)

    authorize @social_media_publication

    respond_to do |format|
      if @social_media_publication.save
        format.turbo_stream { redirect_to edit_scope_of_work_scope_of_work_item_path(@scope_of_work, @scope_of_work_item), notice: 'Social media publication was successfully created.' }
        format.html { redirect_to edit_scope_of_work_scope_of_work_item_path(@scope_of_work, @scope_of_work_item), notice: 'Social media publication was successfully created.' }
      else
        format.turbo_stream
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @social_media_publication = SocialMediaPublication.find(params[:id])
    authorize @social_media_publication

    @scope_of_work_item = @social_media_publication.scope_of_work_item
  end

  def update
    @social_media_publication = SocialMediaPublication.find(params[:id])
    authorize @social_media_publication

    if @social_media_publication.update(social_media_publication_params)
      redirect_to edit_scope_of_work_scope_of_work_item_path(@social_media_publication.scope_of_work, @social_media_publication.scope_of_work_item), notice: 'Social media publication was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @social_media_publication = SocialMediaPublication.find(params[:id])
    authorize @social_media_publication

    @scope_of_work_item = ScopeOfWorkItem.find(params[:scope_of_work_item_id])

    @social_media_publication.destroy

    redirect_to edit_scope_of_work_scope_of_work_item_path(@scope_of_work_item.scope_of_work, @scope_of_work_item), notice: 'Social media publication was successfully destroyed.'
  end


  private
    def social_media_publication_params
      params.require(:social_media_publication).permit(:url, :additional_info, :caption, :post_created_at, :proof, :comments_count, :likes_count, :reach, :impressions, :engagement_rate, :share_count, :manual, :scope_of_work_item_id, :social_media_account_id, :platform, :saves_count)
    end

    def instagram_post_not_found
      respond_to do |format|
        format.html { redirect_to scope_of_work_scope_of_work_item_path(@scope_of_work_item.scope_of_work, @scope_of_work_item), alert: 'Instagram post not found.' }
      end
    end

    def instagram_profile_not_found
      respond_to do |format|
        format.html { redirect_to scope_of_work_scope_of_work_item_path(@scope_of_work_item.scope_of_work, @scope_of_work_item), alert: 'Instagram Profile not found.' }
      end
    end

    def server_error
      respond_to do |format|
        format.html { redirect_to scope_of_work_scope_of_work_item_path(@scope_of_work_item.scope_of_work, @scope_of_work_item), alert: 'Instagram Server error.' }
      end
    end
end
