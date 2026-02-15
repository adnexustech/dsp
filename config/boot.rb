ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
# bootsnap removed for Docker cross-platform compatibility
begin
  require "bootsnap/setup"
rescue LoadError
  # bootsnap not available
end
