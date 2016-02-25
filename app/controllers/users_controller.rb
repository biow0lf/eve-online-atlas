class UsersController < ApplicationController
  before_action :find_user

  def index
    return render status: :bad_request unless @user
    @user.refresh_token_if_expired
    render json: @user.as_json
  end

  def show
    # @user = User.find(params[:id])
  end

  private

  def find_user
    @user = User.find(session[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Session user_id is invalid' }, status: :bad_request
  end
end
