source 'https://rubygems.org'

ruby '>= 3.3.0'

# Rails 8.0
gem 'rails', '~> 8.0.0'

# Database
gem 'mysql2', '~> 0.5'

# Asset Pipeline - Using Sprockets instead of Rails 8 default (Propshaft)
# TODO: Migrate to Propshaft + Importmap for Rails 8 best practices
gem 'sprockets-rails', '~> 3.5'
gem 'sass-rails', '~> 6.0'
# gem 'coffee-rails', '~> 5.0'  # REMOVED: Migrated all CoffeeScript to TypeScript
gem 'terser', '~> 1.1'  # Replaces uglifier for JS compression

# JavaScript
gem 'jquery-rails', '~> 4.6'

# JSON APIs
gem 'jbuilder', '~> 2.13'

# Security
gem 'bcrypt', '~> 3.1.7'

# Bootstrap & UI
gem 'bootstrap_form', '~> 5.0'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'

# Search
gem 'elasticsearch', '~> 8.0'

# Web Server
gem 'puma', '~> 6.0'

# AWS
gem 'aws-sdk-s3', '~> 1.0'  # Use specific S3 gem instead of full aws-sdk
gem 's3_direct_upload'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# CSV library (removed from Ruby 3.4 stdlib)
gem 'csv'

group :development, :test do
  # Debugging
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Testing Framework
  gem 'rspec-rails', '~> 7.0'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.5'
  gem 'shoulda-matchers', '~> 6.0'
end

group :test do
  # Test coverage
  gem 'simplecov', require: false

  # Mocking and stubbing
  gem 'webmock', '~> 3.23'
  gem 'vcr', '~> 6.3'

  # Database cleaner
  gem 'database_cleaner-active_record', '~> 2.2'
end

group :development do
  # Development console
  gem 'web-console', '~> 4.0'

  # Database seeding
  gem 'seed_dump'

  # Speed up development
  # Note: Spring may have compatibility issues with Rails 8
  # gem 'spring'
end

gem "importmap-rails", "~> 2.2"

gem "turbo-rails", "~> 2.0"
gem "stimulus-rails", "~> 1.3"

gem "tailwindcss-rails", "~> 4.3"
