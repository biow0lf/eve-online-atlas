require 'logger'
require 'base64'
class UsersController < ApplicationController
  before_action :find_user

  def index
    return render status: :bad_request unless @user
    refresh_token_if_expired
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

  def refresh_token_if_expired
    if @user.token_expired?
      include HTTParty
      headers = { Authorization: 'Basic ' + Base64.encode64("#{ENV['CREST_CLIENT_ID']}:#{ENV['CREST_CLIENT_SECRET']}") }
      body = { grant_type: 'refresh_token', refresh_token: self.refreshToken}
      response = HTTParty.post('https://login.eveonline.com/oauth/token', body: body.to_json, headers: headers )

      log = Logger.new('log/blah.log')

      log.debug response.body
      log.debug response.body.inspect

      @user.update(token: response.body['token'], expiry: response.body['expires_at'].to_i.seconds + DateTime.now)
    end
  end
end
