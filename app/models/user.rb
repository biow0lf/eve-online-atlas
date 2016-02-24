class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:crest]
  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(refreshToken: data['refreshToken']).first

    logger.debug access_token

    unless user
      include HTTParty
      # use user's access token to get their characterID to make a user
      headers = {'Authorization': 'Bearer ' + data}
      response = HTTParty.get('https://login.eveonline.com/oauth/verify', headers: headers)
      logger.debug response
      user = User.create(characterID: response['characterID'], refreshToken: response['refreshToken'])
    end

    user
  end
end
