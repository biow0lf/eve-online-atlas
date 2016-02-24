class CrestController < ApplicationController
  include HTTParty

  def index
  end

  def create
    data = session['devise.crest_data']
    user = nil
    unless data.nil?
      headers = {'Authorization': 'Bearer ' + data.info}
      response = HTTParty.get('https://login.eveonline.com/oauth/verify', headers: headers)
      logger.debug response
      user = User.create(characterID: response['characterID'], refreshToken: response['refreshToken'])
    end
    unless user.nil?
      render nothing: true, status: 200
    end
    render json: 'Unable to create user', status: 500
  end

end
