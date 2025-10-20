# Docker Setup for ADNEXUS Campaign Manager

This directory contains Docker Compose configurations for running the Campaign Manager in different environments.

## Quick Start (Development)

1. **Build and start all services:**
   ```bash
   docker compose -f docker/compose.yml up --build
   ```

2. **Access the application:**
   - Open http://localhost:3000
   - Default credentials: `demo@ad.nexus` / `adnexus`

3. **Stop services:**
   ```bash
   docker compose -f docker/compose.yml down
   ```

## Development Environment

### Files
- `compose.yml` - Development configuration with hot-reload
- `Dockerfile.dev` - Development image (Ruby 3.3, includes dev tools)

### Features
- **Hot Reload**: Code changes reflect immediately (no rebuild needed)
- **Volume Mounts**: Local code synced with container
- **MySQL 8.0**: Database with persistent storage
- **Redis**: Caching and background jobs
- **Elasticsearch** (optional): Enable with `--profile with-elasticsearch`

### Common Commands

**Start with logs:**
```bash
docker compose -f docker/compose.yml up
```

**Start in background:**
```bash
docker compose -f docker/compose.yml up -d
```

**View logs:**
```bash
docker compose -f docker/compose.yml logs -f web
```

**Run Rails commands:**
```bash
# Rails console
docker compose -f docker/compose.yml exec web bundle exec rails console

# Database setup
docker compose -f docker/compose.yml exec web bundle exec rails db:setup

# Run migrations
docker compose -f docker/compose.yml exec web bundle exec rails db:migrate

# Run tests
docker compose -f docker/compose.yml exec web bundle exec rails test
```

**Access database:**
```bash
docker compose -f docker/compose.yml exec db mysql -u adnexus -padnexus adnexus_dev
```

**Rebuild after Gemfile changes:**
```bash
docker compose -f docker/compose.yml up --build
```

### With Elasticsearch

To start with Elasticsearch for reporting:
```bash
docker compose -f docker/compose.yml --profile with-elasticsearch up
```

Access Elasticsearch at: http://localhost:9200

## Production Environment

### Files
- `compose.prod.yml` - Production configuration
- `Dockerfile` - Multi-stage production image (optimized, small size)
- `.env.example` - Template for environment variables

### Setup

1. **Create environment file:**
   ```bash
   cp docker/.env.example docker/.env
   # Edit docker/.env with your production values
   ```

2. **Generate Rails secrets:**
   ```bash
   # Generate RAILS_MASTER_KEY (first time only)
   docker run --rm ruby:3.3.0-slim sh -c "gem install rails -v 8.0.0 && rails new tmp && cat tmp/config/master.key"

   # Generate SECRET_KEY_BASE
   docker run --rm ruby:3.3.0-slim sh -c "gem install rails -v 8.0.0 && rails secret"
   ```

3. **Build production image:**
   ```bash
   docker compose -f docker/compose.prod.yml build
   ```

4. **Start services:**
   ```bash
   docker compose -f docker/compose.prod.yml up -d
   ```

5. **Setup database (first time):**
   ```bash
   docker compose -f docker/compose.prod.yml exec web bundle exec rails db:setup
   ```

### Production Features
- **Multi-stage build**: Minimal runtime image (~200MB vs 1GB+)
- **Non-root user**: Security hardened
- **Health checks**: Automatic container restart on failure
- **Nginx** (optional): Enable with `--profile with-nginx`
- **Resource limits**: Memory constraints configured
- **Logging**: JSON format with rotation

### Production Commands

**View status:**
```bash
docker compose -f docker/compose.prod.yml ps
```

**Scale web service:**
```bash
docker compose -f docker/compose.prod.yml up -d --scale web=3
```

**View logs:**
```bash
docker compose -f docker/compose.prod.yml logs -f
```

**Database backup:**
```bash
docker compose -f docker/compose.prod.yml exec db \
  mysqldump -u adnexus -p adnexus > backup_$(date +%Y%m%d).sql
```

**Update to new version:**
```bash
# Pull new code
git pull

# Rebuild image
docker compose -f docker/compose.prod.yml build

# Rolling update (no downtime with multiple instances)
docker compose -f docker/compose.prod.yml up -d --no-deps --build web
```

## Troubleshooting

### Rails Won't Start
```bash
# Check logs
docker compose -f docker/compose.yml logs web

# Common fix: remove server.pid
docker compose -f docker/compose.yml exec web rm -f tmp/pids/server.pid
```

### Database Connection Issues
```bash
# Check MySQL is healthy
docker compose -f docker/compose.yml ps

# Restart database
docker compose -f docker/compose.yml restart db

# Wait for database to be ready
docker compose -f docker/compose.yml exec web bundle exec rails db:prepare
```

### Permission Issues (macOS)
```bash
# Fix volume permissions
docker compose -f docker/compose.yml exec -u root web chown -R rails:rails .
```

### Clean Everything
```bash
# Stop and remove all containers, networks, volumes
docker compose -f docker/compose.yml down -v

# Remove images
docker compose -f docker/compose.yml down --rmi all
```

## Architecture

```
┌─────────────┐
│   Nginx     │ (Optional reverse proxy)
│   :80/443   │
└──────┬──────┘
       │
┌──────▼──────┐
│    Web      │ (Rails 8 + Puma)
│   :3000     │
└──┬────┬─────┘
   │    │
   │    └────────┐
   │             │
┌──▼───┐  ┌─────▼─────┐  ┌──────────────┐
│ MySQL│  │   Redis   │  │Elasticsearch │
│ :3306│  │   :6379   │  │    :9200     │
└──────┘  └───────────┘  └──────────────┘
```

## Security Notes

⚠️ **IMPORTANT**:
- Never commit `.env` file with real credentials
- Change all default passwords in production
- Enable SSL/TLS in production (use nginx profile)
- Review security settings in `config/environments/production.rb`
- Fix the `eval()` vulnerability in `config/initializers/1_adnexus.rb` before production use

## Performance Tuning

### Database
- Increase MySQL memory: Edit `ES_JAVA_OPTS` in compose files
- Add indexes: Check `db/schema.rb` for missing indexes
- Use connection pooling: Configured in `config/database.yml`

### Application
- Puma workers: Set `WEB_CONCURRENCY` environment variable
- Puma threads: Set `RAILS_MAX_THREADS` environment variable
- Bootsnap cache: Enabled by default for faster boot

### Elasticsearch
- Increase heap size: Edit `ES_JAVA_OPTS=-Xms2g -Xmx2g`
- Add more nodes for production

## Monitoring

Health check endpoints:
- **Application**: http://localhost:3000/up
- **MySQL**: `mysqladmin ping`
- **Redis**: `redis-cli ping`
- **Elasticsearch**: http://localhost:9200/_cluster/health

## Next Steps

1. ✅ Development setup working
2. ✅ Production configuration ready
3. 🔲 Fix security vulnerabilities (see `LLM.md`)
4. 🔲 Add RSpec test suite
5. 🔲 Set up CI/CD pipeline
6. 🔲 Configure monitoring (Sentry, New Relic)
7. 🔲 SSL/TLS certificates for production
8. 🔲 Database backups automation

---

For more information, see the main project [LLM.md](../LLM.md) which contains the complete Rails 8 upgrade documentation.
