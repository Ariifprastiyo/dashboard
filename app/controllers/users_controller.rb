# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :autheticate_admin_or_super_admin!

  def index
    @users = policy_scope(User).includes([:organization]).order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  # TODO: Guard this action with a policy and scope organization
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_without_password(user_params)
      redirect_to user_path(@user), notice: "User was successfully updated."
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def update_password
    @user = User.find(params[:id])

    if @user.update(user_password_params)
      redirect_to user_path(@user), notice: "User's password was successfully updated."
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def deactivate
    @user = User.find(params[:id])
    @user.deactivate!

    redirect_to users_path
  end

  def activate
    @user = User.find(params[:id])
    @user.activate!

    redirect_to users_path
  end

  private
    def user_params
      if current_user.has_role?(:super_admin) && current_user.has_role?(:admin)
        params.require(:user).permit(:email, :name, :password, :password_confirmation, :organization_id, role_ids: [])
      else
        params.require(:user).permit(:email, :name, :password, :password_confirmation, role_ids: []).merge(organization_id: current_user.organization_id)
      end
    end

    def user_password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
