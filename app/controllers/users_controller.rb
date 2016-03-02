require 'logger'
require 'base64'
class UsersController < ApplicationController
  before_action :find_user
  include HTTParty

  def index
    return render json: {} unless @user
    refresh_token_if_expired
    render json: @user.as_json
  end

  def show
    # @user = User.find(params[:id])
  end

  def location
    return render json: {} unless @user
    refresh_token_if_expired
    headers = { Authorization: 'Bearer ' + @user.token }
    # Route: /characters/<characterID:characterIdType>/contacts/
    response = HTTParty.get("https://public-crest.eveonline.com/characters/#{@user.characterID}/location", headers: headers)
    log = Logger.new('log/location.log')
    data = JSON.parse(response.body)
    log.debug response.body
    log.debug response.body.inspect
    log.debug data
    render json: data
  end

  private

  def find_user
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  def refresh_token_if_expired
    return unless @user.token_expired?
    log = Logger.new('log/location.log')
    log.debug @user

    headers = { Authorization: 'Basic ' + Base64.encode64("#{ENV['CREST_CLIENT_ID']}:#{ENV['CREST_CLIENT_SECRET']}") }
    body = { grant_type: 'refresh_token', refresh_token: refreshToken }
    response = HTTParty.post('https://login.eveonline.com/oauth/token', body: body.to_json, headers: headers)

    log = Logger.new('log/blah.log')
    log.debug response.body
    log.debug response.body.inspect

    @user.update(token: response.body['token'], expiry: response.body['expires_at'].to_i.seconds + DateTime.now)
  end
end
