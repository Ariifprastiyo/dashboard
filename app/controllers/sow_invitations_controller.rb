# frozen_string_literal: true

class SowInvitationsController < ApplicationController
  layout "sow_invitations"

  before_action :check_invitation_validity, except: %i[expired]
  before_action :check_if_already_rejected, only: %i[show update]

  def show
    @sow = ScopeOfWork.find_by(uuid: params[:id])
    @sow_items = @sow.scope_of_work_items.where.not(quantity: 0)
    @social_media_account = @sow.social_media_account
    @influencer = @social_media_account.influencer
    if @sow.management.present?
      media_plan = @sow.media_plan
      sows = media_plan.scope_of_works
      @sow_social_media_account_managements = sows.where.not(management_id: nil)
      @management_sizes = @sow_social_media_account_managements.map { |sow| sow.social_media_account.size }.uniq
      @management_prices = media_plan.scope_of_work_template
    else
      # It will fetch what kind of services are used in the SOW (story, post, story + post, etc.)
      @sows_that_is_used = @sow_items.filter_map { |sow_item| sow_item.name }.uniq
    end
  end

  def update
    # update sow item price and social media account price
    @sow = ScopeOfWork.find_by(uuid: params[:id])
    @social_media_account = @sow.social_media_account

    if @sow.management.present?
      # bulk sow items by social media sizes
      bulk_update_sow_item_price(@sow)
    else
      update_sow_item_price(@sow)
    end

    @sow.last_submitted_at = Time.zone.now
    @sow.status = "accepted"

    respond_to do |format|
      if @social_media_account.update(social_media_account_params) && @sow.save
        format.html { render :update, notice: "SOW was successfully updated." }
        format.turbo_stream
      else
        format.html
        format.turbo_stream
      end
    end
  end

  def reject
    @sow = ScopeOfWork.find_by(uuid: params[:id])
    @sow.last_submitted_at = Time.zone.now
    @sow.rejected!

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def expired; end

  def already_rejected; end


  private
    def social_media_account_params
      prices = ScopeOfWorkItem::PRICES.map { |price| "#{price}_price".to_sym }
      params.require(:social_media_account).permit(prices.push influencer_attributes: {})
    end

    def social_media_account_management_params
      sizes = SocialMediaAccount.sizes.map { |size| size[0].to_sym }
      permited_input = {}
      sizes.each do |size|
        permited_input[size] = {}
      end

      params.require(:social_media_account).permit(permited_input)
    end

    def check_invitation_validity
      sow = ScopeOfWork.find_by(uuid: params[:id])
      campaign = sow.media_plan.campaign

      return if campaign.invitation_expired_at.nil?

      if campaign.invitation_expired_at < Time.zone.now
        redirect_to expired_sow_invitation_path(sow.uuid)
      end
    end

    def check_if_already_rejected
      sow = ScopeOfWork.find_by(uuid: params[:id])

      redirect_to already_rejected_sow_invitation_path(sow.uuid) if sow.rejected?
    end

    def bulk_update_sow_item_price(sow)
      media_plan = sow.media_plan
      sows = media_plan.scope_of_works
      @sow_social_media_account_managements = sows.where.not(management_id: nil)
      social_media_account_management_params.each do |params|
        size = params[0]
        data = params[1]

        scope_of_works = sows.includes(:social_media_account, :scope_of_work_items).where(social_media_account: { size: size })

        scope_of_works.each do |scope_of_work|
          data.each do |name, price|
            sow_item = scope_of_work.scope_of_work_items.where(name: name)
            if !sow_item.update(price: price)
              raise "Error updating sow item price"
            end
          end
        end
      end
    end

    def update_sow_item_price(sow)
      prices = social_media_account_params.select { |key, value| key.include?("_price") }

      prices.each do |key, value|
        sow_item = @sow.scope_of_work_items.where(name: key.gsub("_price", ""))

        if !sow_item.update(price: value)
          raise "Error updating sow item price"
        end
      end
    end
end
