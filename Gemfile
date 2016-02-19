source 'https://rubygems.org'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'rails', '4.2.0'
gem 'sprockets'
gem 'sass-rails'
gem 'compass-rails'
gem 'jquery-rails'
gem 'mysql2', '~> 0.3.18'
gem 'responders'
gem 'coffee-rails'
gem 'angular-rails-templates', '>= 1.0'
gem 'pundit'

source 'https://rails-assets.org' do
  gem 'rails-assets-lodash'
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-ui-router'
  gem 'rails-assets-angular-material'
  gem 'rails-assets-angular-messages'
  gem 'rails-assets-angular-recursion'
  gem 'rails-assets-angular-permission'
  gem 'rails-assets-angular-restmod'
  gem 'rails-assets-ng-rails-csrf'
  gem 'rails-assets-daniel-nagy--md-data-table'
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
