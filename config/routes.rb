Rails.application.routes.draw do
  match '*any' => 'application#options', :via => [:options]

  root 'crest#index'

  get '/thera' => 'crest#thera'

  # everything else falls down to angular's ui-router
  get '*path' => 'crest#index'
end
