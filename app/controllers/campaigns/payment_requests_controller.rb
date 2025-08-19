# frozen_string_literal: true

class Campaigns::PaymentRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :populate_campaign, only: %i[new create index]
  before_action :populate_campaign_beneficiaries, only: %i[new create index]
  before_action :set_payment_request, only: %i[destroy processs pay]
  before_action :set_campaign, only: %i[destroy processs pay]

  # include view helper to use number_to_currency
  include ActionView::Helpers::NumberHelper

  def index
    @q = PaymentRequest.includes(:beneficiary, :payer, :requestor).where({ campaign: @campaign })
                       .order(created_at: :desc).ransack(params[:q])
    @payment_requests = @q.result(distinct: true).page(params[:page]).per(20)

    authorize(@payment_requests)

    add_breadcrumb 'Campaigns', campaigns_path
    add_breadcrumb @campaign.name, campaign_path(@campaign)
  end

  def show
    find_payment_request

    add_breadcrumb 'Campaigns', campaigns_path
    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb 'Payment Requests', campaigns_payment_requests_path(id: @campaign.id)
  end

  def new
    @payment_request = PaymentRequest.new(campaign_id: params[:campaign_id])

    add_breadcrumb 'Campaigns', campaigns_path
    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb 'Payment Requests', campaigns_payment_requests_path(id: @campaign.id)
  end

  def create
    @campaign = policy_scope(Campaign).find(params[:id])

    # Override payment request amount to remove dot
    create_params = payment_request_params
    create_params[:amount] = create_params[:amount].delete('.')

    @payment_request = PaymentRequest.new(create_params)
    if @payment_request.save
      flash[:notice] = 'Payment request has been created'
      redirect_to campaigns_payment_requests_path(id: @campaign.id)
    else
      flash[:alert] = @payment_request.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  # Intentionally using three s's to avoid conflict with update action
  def processs
    check_for_payment_request_rejection; return if performed?

    if @payment_request.update(submit_payment_request_params.merge(status: :processed))
      flash[:notice] = "Payment request to #{@payment_request.beneficiary_name} for #{number_to_currency @payment_request.total_payment} has been processed"
      redirect_to campaigns_payment_requests_path(id: @payment_request.campaign_id)
    else
      flash[:alert] = @payment_request.errors.full_messages.join(', ')
      redirect_to campaigns_payment_request_path(id: @payment_request.campaign_id, payment_request_id: @payment_request.id), status: :unprocessable_entity
    end
  end

  def pay
    authorize @payment_request, :edit?

    check_for_payment_request_rejection; return if performed?

    if @payment_request.update(submit_payment_request_params.merge(status: :paid))
      flash[:notice] = 'Payment request is successfully paid'
      redirect_to campaigns_payment_requests_path(id: @payment_request.campaign_id)
    else
      flash[:alert] = @payment_request.errors.full_messages.join(', ')

      find_payment_request

      add_breadcrumb 'Campaigns', campaigns_path
      add_breadcrumb @campaign.name, campaign_path(@campaign)
      add_breadcrumb 'Payment Requests', campaigns_payment_requests_path(id: @campaign.id)
      render :show, status: :unprocessable_entity
      # redirect_to campaigns_payment_request_path(id: @payment_request.campaign_id, payment_request_id: @payment_request.id), status: :unprocessable_entity
    end
  end

  def destroy
    to = @payment_request.beneficiary_name
    amount = @payment_request.amount
    if @payment_request.update_columns(status: :rejected)
      flash[:notice] = "Payment request to #{to} for #{amount} has been rejected"
      redirect_to campaigns_payment_requests_path(id: @payment_request.campaign_id)
    else
      flash[:alert] = @payment_request.errors.full_messages.join(', ')
      redirect_to campaigns_payment_requests_path(id: @payment_request.campaign_id)
    end
  end

  private
    def check_for_payment_request_rejection
      if params[:commit].downcase == 'reject'
        reject
      end
    end

    def reject
      rejected_params = { status: :rejected, notes: payment_request_params[:notes] }
      if @payment_request.update_columns(rejected_params)
        flash[:notice] = "Payment request to #{@payment_request.beneficiary_name} for #{number_to_currency @payment_request.total_payment} has been rejected"
        redirect_to(campaigns_payment_requests_path(id: @payment_request.campaign_id)) and return
      else
        flash[:alert] = @payment_request.errors.full_messages.join(', ')
        redirect_to(campaigns_payment_requests_path(id: @payment_request.campaign_id), status: :unprocessable_entity) and return
      end
    end

    def submit_payment_request_params
      payment_request_params.permit(:notes, :pph_option, :tax_invoice_number, :ppn, :total_pph, :payer, :payment_proof)
    end

    def pay_payment_request_params
      pay_payment_request_params.permit(:notes, :payment_proof)
    end

    def payment_request_params
      params.require(:payment_request).permit(:amount,
        :due_date, :beneficiary_sgid, :invoice, :payment_proof, :notes, :pph_option, :tax_invoice_number, :ppn, :total_pph)
        .merge(campaign: @campaign, requestor: current_user, payer: current_user)
    end

    def set_campaign
      @campaign = @payment_request.campaign
    end

    def set_payment_request
      @payment_request = PaymentRequest.find_by!(id: params[:payment_request_id], campaign_id: params[:id])
    end

    def populate_campaign
      @campaign = policy_scope(Campaign).find(params[:id])
    end

    def find_payment_request
      @payment_request = PaymentRequest.find_by!(id: params[:payment_request_id], campaign_id: params[:id])
      @campaign = @payment_request.campaign

      @q = PaymentRequest.includes(:beneficiary, :payer, :requestor)
                          .where(campaign_id: @payment_request.campaign_id, beneficiary: @payment_request.beneficiary)
                          .ransack(params[:q])

      @payment_requests = @q.result(distinct: true)
                            .order(created_at: :desc)
    end

    def populate_campaign_beneficiaries
      if @campaign.selected_media_plan.blank?
        @social_media_accounts = SocialMediaAccount.none
        @managements = Management.none
        @beneficiaries = []
        return false
      end

      scope_of_works = @campaign.selected_media_plan.scope_of_works.includes(:social_media_account, :management)
      @social_media_accounts = scope_of_works.filter_map { |sow| sow.social_media_account if sow.management.nil? }
      @managements = scope_of_works.filter_map { |sow| sow.management if sow.management.present? }.uniq
      @beneficiaries = @social_media_accounts + @managements
    end
end
