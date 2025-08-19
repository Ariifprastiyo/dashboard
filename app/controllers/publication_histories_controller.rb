# frozen_string_literal: true

class PublicationHistoriesController < ApplicationController
  # before_action :authenticate_user!

  def new
    @social_media_publication = SocialMediaPublication.find(params[:social_media_publication_id])
    authorize @social_media_publication

    @publication_history = @social_media_publication.publication_histories.build

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @publication_history = PublicationHistory.new(publication_history_params)
    authorize @publication_history

    if @publication_history.save
      redirect_to edit_scope_of_work_scope_of_work_item_path(@publication_history.social_media_publication.scope_of_work_id, @publication_history.social_media_publication.scope_of_work_item_id), notice: 'Publication history was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # only response to turbo stream and with the form
    @publication_history = PublicationHistory.find(params[:id])
    authorize @publication_history

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    @publication_history = PublicationHistory.find(params[:id])

    if @publication_history.update(publication_history_params)
      redirect_to edit_scope_of_work_scope_of_work_item_path(@publication_history.social_media_publication.scope_of_work_id, @publication_history.social_media_publication.scope_of_work_item_id), notice: 'Publication history was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @publication_history = PublicationHistory.find(params[:id])
    authorize @publication_history

    @publication_history.destroy

    redirect_to edit_scope_of_work_scope_of_work_item_path(@publication_history.social_media_publication.scope_of_work_id, @publication_history.social_media_publication.scope_of_work_item_id), notice: 'Publication history was successfully destroyed.'
  end

  private
    def publication_history_params
      params.require(:publication_history).permit(:likes_count, :comments_count, :impressions, :reach, :engagement_rate, :share_count, :social_media_publication_id, :post_created_at, :saves_count)
    end
end
