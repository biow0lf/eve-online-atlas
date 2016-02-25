require 'logger'
class User < ActiveRecord::Base
  def self.create_from_omniauth(auth)
    log = Logger.new('log/tk.log')
    log.debug auth
    log.debug auth.inspect
    create! do |user|
      user.uid = auth['uid']
      user.refreshToken = auth['credentials']['refresh_token']
      user.characterID = auth['info']['character_id']
      user.name = auth['info']['name']
      user.token = auth['credentials']['token']
      user.expiry = auth['info']['expires_on']
    end
  end
end
