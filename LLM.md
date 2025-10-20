# DSP2 Campaign Manager - Rails 8 Upgrade

## Project Overview
DSP2 is the RTB4FREE Campaign Manager - a web interface for managing real-time bidding advertising campaigns. It provides campaign management, targeting, budget controls, and reporting for programmatic advertising.

## Current State (Before Upgrade)
- **Rails Version**: 4.2.11 (released 2019, end-of-life)
- **Ruby Version**: 2.6.10 (system), needs 3.1+ for Rails 8
- **Database**: MySQL
- **Key Dependencies**:
  - sass-rails, coffee-rails (deprecated)
  - jquery-rails
  - bootstrap_form, bootstrap3-datetimepicker
  - elasticsearch 6+
  - aws-sdk, s3_direct_upload
  - puma web server

## Upgrade Plan: Rails 4.2 → Rails 8.0

This is a massive upgrade spanning 9 major/minor versions over almost 10 years. Key milestones:
- Rails 4.2 (2015) → 5.0 → 5.1 → 5.2 → 6.0 → 6.1 → 7.0 → 7.1 → 8.0 (2024)

### Major Breaking Changes to Address

#### Rails 5.0
- Remove `raise_in_transactional_callbacks` config
- Update to newer ActiveRecord API
- Strong parameters required

#### Rails 6.0
- Zeitwerk autoloader (replaces classic autoloader)
- Multiple databases support
- Action Mailbox and Action Text

#### Rails 7.0
- Remove Webpacker, use import maps or Propshaft
- New asset pipeline defaults
- Encrypted credentials become default

#### Rails 8.0
- Solid Queue (background jobs)
- Solid Cache (caching backend)
- Solid Cable (WebSockets)
- Propshaft as default asset pipeline
- Kamal deployment tooling

### Upgrade Steps

1. **Ruby Upgrade** (REQUIRED FIRST)
   - Current: Ruby 2.6.10
   - Required: Ruby 3.1+
   - Recommended: Ruby 3.3.x
   - Use: `rbenv install 3.3.0 && rbenv local 3.3.0`

2. **Gemfile Modernization**
   - Update rails gem to 8.0
   - Replace deprecated gems:
     - sass-rails → cssbundling-rails or keep Sprockets
     - coffee-rails → jsbundling-rails or vanilla JS
     - uglifier → terser or built-in minification
   - Update modern gems:
     - mysql2 to latest
     - elasticsearch to v8
     - aws-sdk to v3

3. **Asset Pipeline Strategy**
   - **Option A**: Keep Sprockets (simpler for this app)
   - **Option B**: Migrate to Propshaft + import maps (Rails 8 default)
   - **Decision**: Keeping Sprockets for now due to existing asset structure

4. **Configuration Updates**
   - Update config/application.rb
   - Update environment files
   - Add new Rails 8 initializers
   - Update secrets.yml → credentials

5. **Database Updates**
   - Update schema for Rails 8 compatibility
   - Check for deprecated column types
   - Verify migrations work

6. **Testing Strategy**
   - Run existing test suite
   - Manual testing of core workflows:
     - User login/logout
     - Campaign creation
     - Targeting configuration
     - Report generation
     - File uploads to S3

## Known Issues & Decisions

### Asset Pipeline Decision
**Issue**: Rails 8 defaults to Propshaft, but this app has complex asset structure with SASS, CoffeeScript, and Bootstrap
**Decision**: Keeping Sprockets (sprockets-rails gem) for now to minimize breaking changes. Can migrate to Propshaft later.

### Ruby Version
**Issue**: System has Ruby 2.6.10, Rails 8 requires 3.1+
**Solution**: User must run `rbenv install 3.3.0 && rbenv local 3.3.0` before bundle install

### CoffeeScript and SASS
**Issue**: CoffeeScript is deprecated, SASS has been replaced by SassC/Dart Sass
**Decision**: Keeping for initial upgrade, can migrate to modern JS/CSS later

### Bootstrap 3
**Issue**: Using bootstrap3-datetimepicker, which may not work with Rails 8
**Solution**: May need to migrate to Bootstrap 5 and modern date picker

## Files Modified

### Gemfile
- Updated rails to 8.0
- Added sprockets-rails (not default in Rails 8)
- Updated all security gems
- Modernized dependencies

### config/application.rb
- Removed deprecated configs
- Added Rails 8 defaults
- Updated autoloader to Zeitwerk

### config/environments/*
- Updated to Rails 8 syntax
- Added new performance settings
- Updated asset compilation settings

## Testing Checklist

- [ ] Application boots without errors
- [ ] Database migrations run successfully
- [ ] Login/logout works
- [ ] Campaign CRUD operations work
- [ ] Targeting configuration works
- [ ] File uploads to S3 work
- [ ] Reports generate correctly
- [ ] API endpoints respond correctly
- [ ] All tests pass

## Post-Upgrade Improvements

Consider after Rails 8 upgrade is stable:
1. Migrate CoffeeScript to modern JavaScript
2. Replace SASS with CSS or Tailwind
3. Update Bootstrap 3 → Bootstrap 5
4. Use Hotwire/Turbo for interactive features
5. Add Solid Queue for background jobs
6. Implement proper credential management
7. Update to latest Elasticsearch client

---

## Rails 8 Upgrade - Completed Configuration

**Date Completed**: 2025-10-20
**Status**: ✅ Configuration Complete - Ready for Testing

### What Was Done

#### 1. Updated Core Files
- ✅ **Gemfile**: Updated to Rails 8.0 with Ruby 3.3
  - Replaced deprecated gems (uglifier → terser, sass-rails 6.0, coffee-rails 5.0)
  - Added bootsnap for faster boot times
  - Updated all dependencies to Rails 8 compatible versions

- ✅ **config/application.rb**: Updated to Rails 8 format
  - Added `config.load_defaults 8.0`
  - Configured autoload_lib for Zeitwerk
  - Kept Sprockets for asset pipeline (maintains compatibility)

- ✅ **config/boot.rb**: Added bootsnap for performance

- ✅ **config/environments/**: Completely rewritten for Rails 8
  - **development.rb**: Added new caching strategy, server timing, verbose query logs
  - **production.rb**: Fixed SECURITY VULNERABILITY - changed log level from :debug to :info
  - Both use `enable_reloading` instead of deprecated `cache_classes`

#### 2. New Initializers
- ✅ **content_security_policy.rb**: Security headers (commented out, ready to enable)
- ✅ **permissions_policy.rb**: Modern browser permissions

#### 3. Docker Setup (Complete)
- ✅ **Dockerfile**: Multi-stage production image (Ruby 3.3, optimized, ~200MB)
- ✅ **Dockerfile.dev**: Development image with hot-reload
- ✅ **docker/compose.yml**: Development environment with MySQL 8, Redis, optional Elasticsearch
- ✅ **docker/compose.prod.yml**: Production-ready with health checks, logging, resource limits
- ✅ **.dockerignore**: Optimized build context
- ✅ **docker/README.md**: Complete documentation for both environments
- ✅ **.ruby-version**: Set to 3.3.0

### Next Steps (User Action Required)

#### To Test Locally:

1. **Start Docker:**
   ```bash
   # If using Colima
   colima start

   # Or if using Docker Desktop
   # Start Docker Desktop application
   ```

2. **Build and run:**
   ```bash
   docker compose -f docker/compose.yml up --build
   ```

3. **Access application:**
   - Open http://localhost:3000
   - Default credentials: `demo@rtb4free.com` / `rtb4free`

4. **Verify functionality:**
   - Login works
   - Campaign CRUD operations work
   - Database connectivity works

### CRITICAL Security Issues to Address

**From the comprehensive security audit, these must be fixed before production:**

1. **CRITICAL**: Remote Code Execution in `config/initializers/1_rtb4free.rb`
   - Lines 9, 16, 18, 20 use `eval()` which allows arbitrary code execution
   - Fix: Replace `eval()` with safe parsing (see report)

2. **CRITICAL**: Hardcoded AWS credentials in same file
   - Lines 77-78 have real AWS keys in source code
   - Fix: Move to Rails credentials or environment variables

3. **CRITICAL**: XSS vulnerability in `app/views/layouts/application.html.erb:146`
   - Using `raw(notice)` allows HTML injection
   - Fix: Use `sanitize()` helper

4. **HIGH**: Missing authorization checks across controllers
   - Users can modify other users' campaigns
   - Fix: Add Pundit authorization gem

5. **HIGH**: No rate limiting for login
   - Brute force attacks possible
   - Fix: Add rack-attack gem

See the comprehensive security report provided for full list of 8 CRITICAL and 7 HIGH severity issues.

### Phase 0 Tasks (Before Production)

Based on the detailed upgrade analysis:

1. Fix eval() RCE vulnerability ⚠️ **URGENT**
2. Remove hardcoded credentials ⚠️ **URGENT**
3. Fix XSS vulnerability ⚠️ **URGENT**
4. Add authorization layer (Pundit)
5. Add rate limiting (rack-attack)
6. Enable force_ssl in production
7. Set up proper session security
8. Add RSpec test suite (0% coverage currently)

---

**Last Updated**: 2025-10-20
**Status**: ✅ Rails 8 Configuration Complete - Ready for Docker Testing
**Next**: User to start Docker and test locally
