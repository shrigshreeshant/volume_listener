#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint volume_listener.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'volume_listener'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to listen to volume key events on iOS'
  s.description      = <<-DESC
  Provides volume key press events for iOS devices.
                       DESC
  s.homepage         = 'https://github.com/folksable/volume_listener'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dhikshith Reddy' => 'dhikshith@folksable.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.frameworks = 'AVFoundation', 'MediaPlayer'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'volume_listener_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
