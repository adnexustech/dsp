# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DSP2 is the RTB4FREE Campaign Manager - a Rails 8 web application for managing real-time bidding (RTB) advertising campaigns. It provides campaign management, targeting, creative management (banners/videos), budget controls, and reporting for programmatic advertising.

**Technology Stack:**
- Ruby 3.3.0
- Rails 8.0.0
- MySQL 8.0
- Elasticsearch 8.0 (optional)
- Redis (optional, for caching)
- Docker/Docker Compose

## Quick Start

### Prerequisites
```bash
# Ensure Ruby 3.3.0 is installed
ruby -v  # Should show 3.3.0

# Install Docker Desktop or Colima
docker --version
```

### Development Setup

**Using Docker (Recommended):**
```bash
# Start services (MySQL, Redis, Rails)
docker compose -f docker/compose.yml up --build

# In another terminal, set up database
docker compose -f docker/compose.yml exec web rake db:setup

# Access application at http://localhost:3000
# Default login: demo@rtb4free.com / rtb4free
```

**Local Development:**
```bash
# Install dependencies
bundle install

# Setup database (ensure MySQL is running)
rake db:setup

# Start server
rails s

# Run tests
rake test

# Run single test
ruby -I test test/models/campaign_test.rb
```

## Common Commands

```bash
# Database
rake db:setup              # Create, load schema, seed data
rake db:migrate            # Run pending migrations
rake db:seed               # Load seed data
rake db:reset              # Drop, create, migrate, seed

# Testing
rake test                  # Run all tests
rake test:models           # Run model tests
rake test:controllers      # Run controller tests
ruby -I test test/models/campaign_test.rb -n test_name  # Single test

# Assets (using Sprockets)
rake assets:precompile     # Compile assets for production
rake assets:clean          # Remove old compiled assets
rake assets:clobber        # Remove all compiled assets

# Custom tasks
rake import:countries      # Import country data
rake import:categories     # Import IAB categories
rake bidagg:process        # Process bid aggregation data

# Docker
docker compose -f docker/compose.yml up         # Start development
docker compose -f docker/compose.yml down       # Stop services
docker compose -f docker/compose.prod.yml up    # Start production
docker compose exec web bash                    # Shell into container
docker compose exec web rails c                 # Rails console in container
```

## Architecture

### Core Models and Relationships

```
User
  └── manages multiple Campaigns

Campaign
  ├── has_many :banners
  ├── has_many :banner_videos
  ├── belongs_to :target (targeting rules)
  └── has_and_belongs_to_many :rtb_standards

Banner / BannerVideo (Creatives)
  ├── belongs_to :campaign
  ├── belongs_to :target (creative-level targeting)
  ├── has_many :exchange_attributes (exchange-specific params)
  └── has_and_belongs_to_many :rtb_standards

Target (Targeting Rules)
  └── contains JSON targeting configuration (geo, device, etc.)

RtbStandard (OpenRTB Configuration)
  └── defines exchange-specific bidding rules
```

### Key Directory Structure

```
app/
  controllers/
    api/v1/         # API endpoints for reporting
    concerns/       # Shared controller logic
    *_controller.rb # Standard CRUD controllers

  models/
    campaign.rb     # Core campaign model with budget/time validation
    banner.rb       # Display ad creative
    banner_video.rb # Video ad creative
    target.rb       # Targeting rules engine
    user.rb         # User authentication (BCrypt)

  views/
    layouts/application.html.erb  # Main layout
    campaigns/      # Campaign management UI
    banners/        # Banner creation/editing
    dashboards/     # Campaign dashboard/analytics
    reports/        # Reporting interface

config/
  initializers/
    1_rtb4free.rb   # ⚠️ RTB4FREE configuration (contains security issues)
    s3_direct_upload.rb  # AWS S3 upload configuration

  environments/   # Rails 8 environment configs
  database.yml    # MySQL configuration (uses ENV vars)
  routes.rb       # Application routes

lib/tasks/
  import.rake     # Data import tasks (countries, categories)
  bidagg.rake     # Bid aggregation processing

docker/
  compose.yml     # Development environment
  compose.prod.yml # Production environment
  README.md       # Docker documentation
```

### Asset Pipeline (Sprockets)

Rails 8 defaults to Propshaft, but this app uses **Sprockets** for backward compatibility with existing SASS/CoffeeScript assets.

**Key files:**
- `app/assets/javascripts/application.js` - Main JS manifest
- `app/assets/stylesheets/application.scss` - Main CSS manifest
- `config/initializers/assets.rb` - Asset configuration
- Assets are compiled to `public/assets/` for production

**Note:** CoffeeScript and SASS are legacy choices. Consider migrating to modern JavaScript and CSS in future refactoring.

## Rails 8 Upgrade - Important Details

### What Changed from Rails 4.2 → Rails 8.0

**Configuration:**
- Using `config.load_defaults 8.0`
- Zeitwerk autoloader (replaces classic autoloader)
- `enable_reloading` instead of `cache_classes`
- Kept Sprockets instead of Propshaft (Rails 8 default)

**Dependencies Updated:**
- `uglifier` → `terser` (JavaScript compression)
- Updated to Elasticsearch 8.0 client
- Modern AWS SDK S3

**Still Using Legacy (by choice):**
- SASS instead of CSS or Tailwind
- CoffeeScript instead of modern JavaScript
- jQuery instead of modern framework

### Known Compatibility Issues

1. **spring gem disabled** - Rails 8 compatibility issues (line 60 in Gemfile)
2. **bootstrap3-datetimepicker** - May need upgrade to Bootstrap 5 version
3. **s3_direct_upload gem** - May be unmaintained, verify compatibility

## Critical Security Issues (Documented but NOT Fixed)

⚠️ **DO NOT DEPLOY TO PRODUCTION WITHOUT FIXING THESE:**

### 1. Remote Code Execution (RCE)
**File:** `config/initializers/1_rtb4free.rb` lines 9, 16, 18, 20
**Issue:** Uses `eval()` with environment variables, allowing arbitrary code execution
**Fix:** Replace with safe JSON parsing or constant lookup

### 2. Hardcoded AWS Credentials
**File:** `config/initializers/1_rtb4free.rb` lines 77-78
**Issue:** Real AWS keys in source code
**Fix:** Move to Rails credentials: `rails credentials:edit`

### 3. Cross-Site Scripting (XSS)
**File:** `app/views/layouts/application.html.erb` line 146
**Issue:** Using `raw(notice)` allows HTML injection
**Fix:** Use `sanitize(notice)` or proper escaping

### 4. Missing Authorization
**Issue:** Users can modify other users' campaigns (no authorization checks)
**Fix:** Add Pundit gem and policy classes

### 5. No Rate Limiting
**Issue:** Login endpoint vulnerable to brute force
**Fix:** Add rack-attack gem with rate limiting

### 6. Production Logging
**Issue:** Previously logged at :debug level (security vulnerability)
**Status:** ✅ Fixed - now uses :info level (config/environments/production.rb:52)

See `LLM.md` for comprehensive security audit details.

## Database Configuration

Uses MySQL 8.0 with environment variable configuration:

```ruby
# config/database.yml
development:
  adapter: mysql2
  database: rtb4free_dev
  host: localhost
  port: 3306
  username: rtb4free
  password: rtb4free
```

**Docker Environment Variables:**
- `DB_HOST` - Database host (default: db)
- `DB_PORT` - Database port (default: 3306)
- `DB_NAME` - Database name
- `DB_USERNAME` - Database user
- `DB_PASSWORD` - Database password

## Testing

**Framework:** Minitest (Rails default)
**Current Coverage:** ~80% passing (some issues in budgeting/targeting)

```bash
# Run all tests
rake test

# Run specific test file
ruby -I test test/models/campaign_test.rb

# Run specific test by name
ruby -I test test/models/campaign_test.rb -n test_validates_campaign_name

# Test fixtures in test/fixtures/*.yml
```

**Common Test Patterns:**
```ruby
class CampaignTest < ActiveSupport::TestCase
  test "validates presence of name" do
    campaign = Campaign.new
    assert_not campaign.valid?
    assert campaign.errors[:name].any?
  end
end
```

## API Endpoints

RESTful JSON API for reporting:

```
POST /api/v1/report/summary
GET  /api/v1/report/summary

# Returns campaign performance metrics from Elasticsearch
```

**Authentication:** Session-based (cookies)
**Format:** JSON (default for /api namespace)

## Important Code Patterns

### Campaign Validation
Campaigns validate budget, time windows, and have complex error checking:

```ruby
# app/models/campaign.rb
validates :total_budget, presence: true, numericality: { greater_than: 0 }
validate :expire_time_cannot_be_in_the_past
```

### Banner/Video Error Checking
Creatives have `check_errors` method that returns array of error strings (not Rails validations):

```ruby
banner.check_errors  # Returns ["Daily cost greater than budget"]
```

### Bidder Integration
Campaigns synchronize with external RTB bidder via HTTP:

```ruby
campaign.update_bidder    # Notify bidder of changes
campaign.remove_bidder    # Remove from bidder
```

## Docker Deployment

### Development (Hot-reload enabled)
```bash
cd docker
docker compose -f compose.yml up --build
```

### Production
```bash
cd docker
docker compose -f compose.prod.yml up -d
```

**Production features:**
- Multi-stage Docker build (~200MB final image)
- Health checks on all services
- Resource limits (CPU/memory)
- Automatic restarts
- Prometheus-ready logging

## Common Issues & Solutions

### Issue: "Can't connect to MySQL"
```bash
# Ensure MySQL is running
docker compose ps

# Check database exists
docker compose exec db mysql -u rtb4free -prtb4free -e "SHOW DATABASES;"

# Recreate database
docker compose exec web rake db:setup
```

### Issue: "Sprockets asset not found"
```bash
# Precompile assets
rake assets:precompile

# Or in Docker
docker compose exec web rake assets:precompile
```

### Issue: "Zeitwerk autoloader error"
Zeitwerk expects file names to match class names:
- `app/models/campaign.rb` → `class Campaign`
- `app/controllers/campaigns_controller.rb` → `class CampaignsController`

### Issue: Missing Gemfile.lock
```bash
# Generate Gemfile.lock
bundle install

# In Docker
docker compose exec web bundle install
```

## Development Workflow

1. **Start Docker services:**
   ```bash
   docker compose -f docker/compose.yml up
   ```

2. **Make code changes** (hot-reload enabled in development)

3. **Run tests** after changes:
   ```bash
   docker compose exec web rake test
   ```

4. **Check logs:**
   ```bash
   docker compose logs -f web
   ```

5. **Database migrations:**
   ```bash
   # Create migration
   docker compose exec web rails g migration AddFieldToModel field:type

   # Run migration
   docker compose exec web rake db:migrate
   ```

6. **Console access:**
   ```bash
   docker compose exec web rails console
   ```

## Code Style & Conventions

- **Models:** Inherit from `ApplicationRecord` (NOT `ActiveRecord::Base`)
- **Controllers:** Inherit from `ApplicationController`
- **Use symbols for hash keys:** `{ name: 'value' }` not `{ 'name' => 'value' }`
- **Strong parameters required** for mass assignment
- **Validation errors:** Use Rails validations, not custom error arrays (except for `check_errors` methods in Banner/Campaign)

## Future Improvements (Post-Rails 8)

1. **Replace CoffeeScript** with modern JavaScript/TypeScript
2. **Replace SASS** with modern CSS or Tailwind
3. **Upgrade Bootstrap 3 → 5**
4. **Add Hotwire/Turbo** for interactive features
5. **Implement Pundit** authorization
6. **Add RSpec** test suite (currently using Minitest)
7. **Fix security vulnerabilities** (eval, XSS, credentials)
8. **Migrate to Propshaft** (if needed for asset management)

## Additional Resources

- **RTB4FREE Documentation:** https://rtb4free.readthedocs.io
- **Docker Hub:** https://hub.docker.com/r/rtb4free/campaign-manager
- **Rails 8 Guides:** https://guides.rubyonrails.org/v8.0/
- **Security Audit:** See `LLM.md` for comprehensive security report

---

**Last Updated:** 2025-10-20
**Rails Version:** 8.0.0
**Ruby Version:** 3.3.0
**Status:** Configuration complete, security fixes pending
