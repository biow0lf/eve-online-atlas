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

  def token_expired?
    expiry = Time.at(self.expiry)
    # +6 hours to get to UTC 0
    return true if expiry < Time.now + 6.hours
    false
  end
end
