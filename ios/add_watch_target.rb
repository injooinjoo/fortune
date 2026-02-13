#!/usr/bin/env ruby
require 'xcodeproj'

# Open the project
project_path = '/Users/jacobmac/Desktop/Dev/fortune/ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Check if FortuneWatch target already exists
if project.targets.find { |t| t.name == 'FortuneWatch' }
  puts "FortuneWatch target already exists!"
  exit 0
end

puts "Adding FortuneWatch target..."

# Create watchOS app target
watch_target = project.new_target(
  :watch2_app,
  'FortuneWatch',
  :watchos,
  '9.0'
)

# Set bundle identifier
watch_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.beyond.fortune.watchapp'
  config.build_settings['INFOPLIST_FILE'] = 'FortuneWatch/Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'FortuneWatch/FortuneWatch.entitlements'
  config.build_settings['DEVELOPMENT_TEAM'] = '$(DEVELOPMENT_TEAM)'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '4' # Watch
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '9.0'
  config.build_settings['SDKROOT'] = 'watchos'
  config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
  config.build_settings['SKIP_INSTALL'] = 'YES'
end

# Find or create FortuneWatch group
watch_group = project.main_group.find_subpath('FortuneWatch', true)
watch_group.set_source_tree('<group>')
watch_group.set_path('FortuneWatch')

# Add Swift files to the target
swift_files = Dir.glob('/Users/jacobmac/Desktop/Dev/fortune/ios/FortuneWatch/**/*.swift')
swift_files.each do |file_path|
  relative_path = file_path.sub('/Users/jacobmac/Desktop/Dev/fortune/ios/FortuneWatch/', '')

  # Create subdirectories in the group
  components = relative_path.split('/')
  current_group = watch_group

  if components.length > 1
    components[0..-2].each do |dir|
      subgroup = current_group.find_subpath(dir, false)
      if subgroup.nil?
        subgroup = current_group.new_group(dir, dir)
      end
      current_group = subgroup
    end
  end

  # Add file reference
  file_name = components.last
  file_ref = current_group.new_file(file_name)

  # Add to target's compile sources
  watch_target.add_file_references([file_ref])
end

# Add Info.plist
info_plist_path = '/Users/jacobmac/Desktop/Dev/fortune/ios/FortuneWatch/Info.plist'
if File.exist?(info_plist_path)
  info_ref = watch_group.new_file('Info.plist')
end

# Add entitlements
entitlements_path = '/Users/jacobmac/Desktop/Dev/fortune/ios/FortuneWatch/FortuneWatch.entitlements'
if File.exist?(entitlements_path)
  ent_ref = watch_group.new_file('FortuneWatch.entitlements')
end

# Add Assets.xcassets if exists
assets_path = '/Users/jacobmac/Desktop/Dev/fortune/ios/FortuneWatch/Assets.xcassets'
if File.exist?(assets_path)
  assets_ref = watch_group.new_file('Assets.xcassets')
  watch_target.add_resources([assets_ref])
end

# Add dependency to main Runner target
main_target = project.targets.find { |t| t.name == 'Runner' }
if main_target
  # Create embed watch content build phase
  embed_phase = main_target.new_copy_files_build_phase('Embed Watch Content')
  embed_phase.dst_subfolder_spec = '16' # Watch app
  embed_phase.dst_path = '$(CONTENTS_FOLDER_PATH)/Watch'

  # Add watch app to embed phase
  watch_product = watch_target.product_reference
  if watch_product
    build_file = embed_phase.add_file_reference(watch_product)
    build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
  end

  # Add target dependency
  main_target.add_dependency(watch_target)
end

# Save the project
project.save

puts "FortuneWatch target added successfully!"
puts "Please open Xcode and:"
puts "1. Select FortuneWatch scheme"
puts "2. Set up signing (Team)"
puts "3. Build and run"
