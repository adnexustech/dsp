# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "stylesheets")

# Precompile style variations
Rails.application.config.assets.precompile += [
  "styles/*",
  "styles/flat/*",
  "styles/futurico/*",
  "styles/line/*",
  "styles/minimal/*",
  "styles/polaris/*",
  "styles/square/*"
]

# Precompile font files
Rails.application.config.assets.precompile += %w( .svg .eot .woff .ttf .woff2 )

# Precompile per-controller assets (Rails 4 pattern - consider refactoring)
# Note: This pattern is deprecated and should be migrated to modern asset bundling
Dir[Rails.root.join('app/controllers/*_controller.rb')].each do |path|
  if match = path.match(/(\w+)_controller.rb/)
    controller = match[1]
    Rails.application.config.assets.precompile += [
      "#{controller}.js.coffee",
      "#{controller}.coffee",
      "#{controller}.css",
      "#{controller}.js"
    ]
  end
end

# Additional JavaScript files
Rails.application.config.assets.precompile += %w(
  application_scriptedit.js
  application_s3upload.js
)




