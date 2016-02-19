Rails.application.routes.draw do
  match '*any' => 'application#options', :via => [:options]

  root 'crest#index'

  # everything else falls down to angular's ui-router
  get '*path' => 'crest#index'
end
