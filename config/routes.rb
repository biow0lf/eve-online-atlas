Rails.application.routes.draw do
  match '*any' => 'application#options', :via => [:options]

  root 'crest#index'

  get '/thera' => 'crest#thera'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :items, only: [:index, :show]
      resources :solarsystems, only: [:index, :show]
	  resources :agents, only: [:index, :show]
    end
  end

  # everything else falls down to angular's ui-router
  get '*path' => 'crest#index'
end
