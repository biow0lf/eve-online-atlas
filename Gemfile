source 'https://rubygems.org'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'rails', '4.2.0'
gem 'sprockets'
gem 'sass'
gem 'sass-rails'
gem 'compass-rails'
gem 'jquery-rails'
gem 'mysql2', '~> 0.3.18'
gem 'responders'
gem 'coffee-rails'
gem 'angular-rails-templates', '>= 1.0'
gem 'pundit'
gem 'httparty'
gem 'composite_primary_keys'
gem 'omniauth-crest'
gem 'devise'
# gem 'reve', :git => 'git@github.com:lisa/reve.git'

source 'https://rails-assets.org' do
  gem 'rails-assets-lodash'
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-ui-router'
  gem 'rails-assets-ui-router-extras'
  gem 'rails-assets-angular-material'
  gem 'rails-assets-angular-messages'
  gem 'rails-assets-angular-permission'
  gem 'rails-assets-ng-rails-csrf'
  gem 'rails-assets-daniel-nagy--md-data-table'
  gem 'rails-assets-ng-file-upload'
  gem 'rails-assets-moment'
  gem 'rails-assets-angular-moment', '1.0.0.beta.4'
end

group :development do
  gem 'meta_request'
  gem 'rails-erd'
end

group :development, :test do
  gem 'rubocop'
  gem 'rails-assets-angular-mocks'
  gem 'teaspoon-jasmine'
  gem 'phantomjs'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'simplecov', require: false
end

group :production do
  gem 'uglifier', '>= 1.3.0'
  gem 'therubyracer'
  gem 'fog'
end
