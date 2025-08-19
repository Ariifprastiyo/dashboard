# frozen_string_literal: true

class EmploymentAgreementLettersController < ApplicationController
  before_action :set_data

  layout "sow_invitations"

  def download
    @media_plan = @scope_of_work.media_plan
    @influencer = @scope_of_work.social_media_account.influencer

    respond_to do |format|
      format.html
      format.pdf do
        if @scope_of_work.management.present?
          @total = @media_plan.scope_of_works.where(management_id: @scope_of_work.management_id).sum(:total)
          @total_influencer = @media_plan.scope_of_works.where(management_id: @scope_of_work.management_id).count

          pdf = ManagementInfluencerAgreementLetterPdf.new(@media_plan, @scope_of_work, @influencer, view_context, @total, @total_influencer)

          filename = "SPK-#{@scope_of_work.management.name}.pdf"
        else
          pdf = InfluencerAgreementLetterPdf.new(@media_plan, @scope_of_work, @influencer, view_context)
          filename = "SPK-#{@influencer.name}.pdf"
        end
        send_data(pdf.render,
          filename: filename,
          type: "application/pdf")
      end
    end
  end

  def show
    @social_media_account = @scope_of_work.social_media_account
    @influencer = @social_media_account.influencer
  end

  def update
    respond_to do |format|
      if @scope_of_work.update(agreement_letter_params)
        format.html { render :update, notice: "SPK was successfully uploaded." }
        format.turbo_stream
      else
        format.html
        format.turbo_stream
      end
    end
  end

  private
    def set_data
      @scope_of_work = ScopeOfWork.find_by!(uuid: params[:id])
    end

    def agreement_letter_params
      params.require(:scope_of_work).permit(:agreement_letter)
    end
end
