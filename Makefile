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
	bundle install

# Database setup
db-setup:
	@echo "Creating database..."
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:create
	@echo "Running migrations..."
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:migrate
	@echo "Database setup complete!"

db-migrate:
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:migrate

db-reset:
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:drop
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:create
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:migrate
	@echo "Database reset complete!"

db-seed:
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails db:seed

# Development servers
server:
	@echo "Starting Rails server on http://localhost:4000"
	@echo "Stop with Ctrl+C"
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free RUBYOPT="-W0" bundle exec rails server -p 4000 -b 0.0.0.0

dev:
	@echo "Starting development environment..."
	@echo "Rails server: http://localhost:4000"
	@echo "Stop with Ctrl+C"
	@if command -v foreman >/dev/null 2>&1; then \
		DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free RUBYOPT="-W0" foreman start -f Procfile.dev; \
	else \
		echo "Foreman not found. Install with: gem install foreman"; \
		echo "Starting Rails server only..."; \
		DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free RUBYOPT="-W0" bundle exec rails server -p 4000 -b 0.0.0.0; \
	fi

# Console
console:
	DB_HOST=127.0.0.1 DB_PORT=3306 DB_USERNAME=rtb4free DB_PASSWORD=rtb4free bundle exec rails console

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
