Rails.application.config.middleware.use OmniAuth::Builder do
  provider :crest, ENV['CREST_CLIENT_ID'], ENV['CREST_CLIENT_SECRET'], scope: 'characterLocationRead publicData'
end
