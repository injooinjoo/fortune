source "https://rubygems.org"

gem "fastlane"

# Optional: For screenshot generation
gem "fastlane-plugin-screengrab"
gem "fastlane-plugin-frameit"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)