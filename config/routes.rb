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

  mount Crono::Web, at: '/crono'

  root 'crest#index'

  get '/thera' => 'crest#thera'

  get '/auth/:provider/callback' => 'sessions#create'
  # get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  resources :sessions, only: [:destroy]
  resources :users, only: [:index, :show]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      root to: proc { version_info }
      resources :items, only: [:index, :show] do
        collection do
          get '/price', to: 'items#price'
        end
        collection do
          get '/history', to: 'items#history'
        end
      end
      resources :solarsystems, only: [:index, :show] do
        resources :planets, only: [:index, :show] do
          resources :moons, only: [:index, :show]
        end
        resources :stations, only: [:index, :show] do
          resources :agents, only: [:index, :show]
        end
        member do
          get '/neighbors', to: 'solarsystems#get_neighbors'
        end
      end
    end
  end
  # everything else falls down to angular's ui-router
  get '*path' => 'crest#index', constraints: -> (req) do
    !(req.fullpath =~ %r{^(\/assets\/.*)|^(so\?origin=.*)|^(authorize\?client_id=.*)|^(callback\?code=.*)|^(\/auth\/so.*)})
  end
end
