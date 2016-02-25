include 'logger'
class User < ActiveRecord::Base
  def self.create_from_omniauth(auth)
    log = Logger.new('log/tk.log')
    log.debug auth
    log.debug auth.inspect
    create! do |user|
      user.uid = auth['uid']
    end
  end
end
