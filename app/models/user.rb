class User < ActiveRecord::Base
  def self.create_from_omniauth(access_token)
    logger.debug access_token
    data = access_token.info
    user = User.where(refreshToken: data['refreshToken']).first

    unless user
      include HTTParty
      # use user's access token to get their characterID to make a user
      headers = {'Authorization': 'Bearer ' + data}
      response = HTTParty.get('https://login.eveonline.com/oauth/verify', headers: headers)
      logger.debug response
      user = User.create(characterID: response['characterID'], refreshToken: response['refreshToken'])
    end

    user

    # self.create(provider: auth_hash[:provider],
    #             uid: auth_hash[:uid],
    #             name: auth_hash[:info][:name])
  end
end
