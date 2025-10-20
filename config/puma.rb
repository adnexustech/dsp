# Puma configuration file for Rails 8

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_count` to boot in cluster mode.
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Preload the application before starting the worker processes.
preload_app!

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Worker specific setup for Rails
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
