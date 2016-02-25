require 'base64'
require 'logger'
class User < ActiveRecord::Base
  def self.create_from_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.refreshToken = auth['credentials']['refresh_token']
      user.characterID = auth['info']['character_id']
      user.name = auth['info']['name']
      user.token = auth['credentials']['token']
      user.expiry = auth['info']['expires_on']
    end
  end

  def refresh_token_if_expired
    if token_expired?
      include HTTParty
      headers = { Authorization: 'Basic ' + Base64.encode64("#{ENV['CREST_CLIENT_ID']}:#{ENV['CREST_CLIENT_SECRET']}") }
      body = { grant_type: 'refresh_token', refresh_token: self.refreshToken}
      response = HTTParty.post('https://login.eveonline.com/oauth/token', body: body.to_json, headers: headers )

      log = Logger.new('log/blah.log')

      log.debug response.body
      log.debug response.body.inspect

      self.token = response.body['token']
      self.expiry = response.body['expires_at'].to_i.seconds + DateTime.now
    end
  end

  def token_expired?
    expiry = Time.at(self.expiry)
    return true if expiry < Time.now
    false
  end
end
