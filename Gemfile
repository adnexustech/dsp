source 'https://rubygems.org'

ruby '>= 3.3.0'

# Rails 8.0
gem 'rails', '~> 8.0.0'

# Database
gem 'pg', '~> 1.5'

# Modern Asset Pipeline
gem 'propshaft'  # Rails 8 asset pipeline

# JSON APIs
gem 'jbuilder', '~> 2.13'

# Security
gem 'bcrypt', '~> 3.1.7'

# Payments
gem 'stripe', '~> 12.0'

# Modern View Components
gem 'phlex-rails', '~> 2.0'

# Bootstrap Forms (temporary - migrate to Phlex)
gem 'bootstrap_form', '~> 5.0'

# Search
gem 'elasticsearch', '~> 8.0'

# Web Server
gem 'puma', '~> 6.0'

# Background Jobs
gem 'sidekiq', '~> 7.0'
gem 'redis', '~> 5.0'

# AWS
gem 'aws-sdk-s3', '~> 1.0'  # Use specific S3 gem instead of full aws-sdk
gem 's3_direct_upload'

# bootsnap removed - native extensions fail in cross-platform Docker builds

# CSV library (removed from Ruby 3.4 stdlib)
gem 'csv'

group :development, :test do
  # Environment variables
  gem 'dotenv-rails', '~> 3.1'

  # Debugging
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Testing Framework
  gem 'rspec-rails', '~> 7.0'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.5'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'rails-controller-testing', '~> 1.0'  # Provides assigns/assert_template for controller specs
end

group :test do
  # Test coverage
  gem 'simplecov', require: false

  # Mocking and stubbing
  gem 'webmock', '~> 3.23'
  gem 'vcr', '~> 6.3'

  # Database cleaner
  gem 'database_cleaner-active_record', '~> 2.2'

  # E2E Testing
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.25'
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
