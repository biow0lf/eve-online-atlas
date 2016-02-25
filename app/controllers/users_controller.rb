class UsersController < ApplicationController
  # before_action :authenticate_user!
  # before_action :current_user?, except: [:index]

  def index
    # @users = User.all
    user = User.find(session[:user_id]) if session[:user_id]
    render json: user.as_json
  end

  def show
    # @user = User.find(params[:id])
  end
end
