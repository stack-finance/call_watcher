#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint call_watcher.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'call_watcher'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for fetching call logs'
  s.description      = <<-DESC
  Flutter plugin for querying and fetching call logs, uses `CallKit` Observer and maintains a local database to store call logs on iOS,
  and uses `ContentResolver` to fetch call logs on Android.
                       DESC
  s.homepage         = 'https://github.com/stackfinance/call_watcher'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Dhikshith Reddy' => 'dhikshith@stackfinance.co' }
  s.source           = { :path => '.' }
  s.source_files = 'CallLogManager/Sources/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'call_watcher_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
