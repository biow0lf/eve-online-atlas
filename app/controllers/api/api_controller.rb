require 'net/http'
module Api
  class ApiController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :login_required
    # before_action :authenticate

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordNotSaved, with: :record_not_saved
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

    def authenticate
      return if current_user
      return render json: { error: 'No authorization header defined' }, status: :unauthorized unless request.authorization
      data = open(ENV['AUTH_PROVIDER_URL'] + '/oauth/token/info', 'Authorization' => request.authorization).read
      data = JSON.parse(data) if data
      user = User.where(identity_id: data['resource_owner_id']).first
      session[:user_id] = user.id
    end

    private

    def record_not_found(exception = 'Record not found')
      body = exception.class == String ? { error: exception } : { error: exception.message }
      render json: body, status: :bad_request
    end

    def record_not_saved
      render json: { error: 'Record failed to save. You are probably missing a required parameter.' },
             status: :unprocessable_entity
    end

    def record_invalid(exception)
      render json: { error: exception.message }, status: :bad_request
    end
  end
end
