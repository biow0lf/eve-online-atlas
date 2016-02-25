Rails.application.routes.draw do

  def version_info
    [200,
     { 'Content-Type': 'application/json' },
     [{ app_version: APP_VERSION,
        ruby_version: "#{RUBY_ENGINE}-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}",
        rails_version: Rails.version
      }.to_json]]
  end

  match '*any' => 'application#options', :via => [:options]

  root 'crest#index'

  get '/thera' => 'crest#thera'

  get '/auth/:provider/callback' => 'sessions#create'
  # get '/signin' => 'sessions#new', :as => :signin
  # get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  # resources :sessions, only: [:new, :destroy]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      root to: proc { version_info }
      resources :items, only: [:index, :show]
      resources :solarsystems, only: [:index, :show]
    end
  end

  # everything else falls down to angular's ui-router
  get '*path' => 'crest#index', constraints: -> (req) do
    !(req.fullpath =~ %r{^(\/assets\/.*)|^(so\?origin=.*)|^(authorize\?client_id=.*)|^(callback\?code=.*)|^(\/auth\/so.*)})
  end
end
