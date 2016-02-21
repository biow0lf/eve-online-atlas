require 'net/http'
module Api
  class ApiController < ApplicationController
    skip_before_action :login_required
    # before_action :authenticate
    skip_before_action :verify_authenticity_token

    def authenticate
      return if current_user
      return render json: { error: 'No authorization header defined' }, status: :unauthorized unless request.authorization
      data = open(ENV['AUTH_PROVIDER_URL'] + '/oauth/token/info', 'Authorization' => request.authorization).read
      data = JSON.parse(data) if data
      user = User.where(identity_id: data['resource_owner_id']).first
      session[:user_id] = user.id
    end
  end
end
