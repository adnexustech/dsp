.PHONY: help install server dev test db-setup db-migrate db-reset db-seed console routes lint clean

# Default target
help:
	@echo "AdNexus DSP - Available Commands"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make install      - Install dependencies (bundle install)"
	@echo "  make db-setup     - Create and setup database"
	@echo ""
	@echo "Development:"
	@echo "  make dev          - Start development server with Tailwind watcher"
	@echo "  make server       - Start Rails server only (port 3000)"
	@echo "  make console      - Open Rails console"
	@echo ""
	@echo "Database:"
	@echo "  make db-migrate   - Run database migrations"
	@echo "  make db-reset     - Reset database (drop, create, migrate, seed)"
	@echo "  make db-seed      - Seed database with sample data"
	@echo ""
	@echo "Testing & Quality:"
	@echo "  make test         - Run all tests"
	@echo "  make lint         - Check code with Rubocop"
	@echo ""
	@echo "Utilities:"
	@echo "  make routes       - Show all routes"
	@echo "  make clean        - Clean temporary files and logs"
	@echo ""

# Installation
install:
	/opt/homebrew/opt/ruby/bin/bundle install

# Database setup (uses defaults from config/database.yml)
db-setup:
	@echo "Creating database..."
	RUBYOPT="-W0" bin/rails db:create
	@echo "Running migrations..."
	RUBYOPT="-W0" bin/rails db:migrate
	@echo "Seeding database..."
	RUBYOPT="-W0" bin/rails db:seed
	@echo "✅ Database setup complete!"
	@echo ""
	@echo "Login credentials:"
	@echo "  Email: demo@ad.nexus"
	@echo "  Password: adnexus"

db-migrate:
	RUBYOPT="-W0" bin/rails db:migrate

db-reset:
	RUBYOPT="-W0" bin/rails db:drop
	RUBYOPT="-W0" bin/rails db:create
	RUBYOPT="-W0" bin/rails db:migrate
	RUBYOPT="-W0" bin/rails db:seed
	@echo "✅ Database reset complete!"
	@echo ""
	@echo "Login credentials:"
	@echo "  Email: demo@ad.nexus"
	@echo "  Password: adnexus"

db-seed:
	RUBYOPT="-W0" bin/rails db:seed

# Development servers
server:
	@echo "Starting Rails server on http://localhost:4000"
	@echo "Stop with Ctrl+C"
	@echo ""
	@echo "Login: demo@ad.nexus / adnexus"
	@echo ""
	RUBYOPT="-W0" bin/rails server -p 4000 -b 0.0.0.0

dev:
	@echo "Starting development environment..."
	@echo "Rails server: http://localhost:4000"
	@echo "Stop with Ctrl+C"
	@echo ""
	@echo "Login: demo@ad.nexus / adnexus"
	@echo ""
	@if command -v foreman >/dev/null 2>&1; then \
		RUBYOPT="-W0" foreman start -f Procfile.dev; \
	else \
		echo "Foreman not found. Install with: gem install foreman"; \
		echo "Starting Rails server only..."; \
		RUBYOPT="-W0" bin/rails server -p 4000 -b 0.0.0.0; \
	fi

# Console
console:
	RUBYOPT="-W0" bin/rails console

# Testing
test:
	@echo "Running tests..."
	bundle exec rails test

# Code quality
lint:
	@if command -v rubocop >/dev/null 2>&1; then \
		bundle exec rubocop; \
	else \
		echo "Rubocop not installed. Add to Gemfile: gem 'rubocop'"; \
	fi

# Utilities
routes:
	bundle exec rails routes

clean:
	@echo "Cleaning temporary files..."
	rm -rf tmp/cache
	rm -rf tmp/pids
	rm -rf log/*.log
	@echo "Clean complete!"

# Assets
assets-precompile:
	bundle exec rails assets:precompile

assets-clean:
	bundle exec rails assets:clobber

# Tailwind CSS
tailwind-build:
	bundle exec rails tailwindcss:build

tailwind-watch:
	bundle exec rails tailwindcss:watch
