#
# Be sure to run `pod lib lint MLYSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MLYSDK'
  s.version          = '0.1.16'
  s.summary          = 'A short description of MLYSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/patricelee/poc-mly-avplayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MLY' => 'ios-dev@letron.tech' }
  s.source           = { :git => 'https://github.com/patricelee/poc-mly-avplayer.git', :tag => s.version.to_s }
  
  s.readme = "https://raw.githubusercontent.com/patricelee/poc-mly-avplayer/main/README.md"

  s.swift_version = '5.0'
  
  s.ios.deployment_target = '14.0'
 
 s.ios.vendored_frameworks = 'archives/MLYSDK.xcframework'
  
#  s.source_files = 'Sources/MLYSDK/Classes/**/*'

# s.public_header_files = 'Pod/Classes/**/*.h'

  # s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64', 'ENABLE_BITCODE' => 'NO' }
  
  s.frameworks = 'AVFoundation'
  
  s.dependency 'Mux-Stats-AVPlayer', '~> 3.1.0'
  s.dependency 'GCDWebServer', '~> 3.5.4'
  s.dependency 'Sentry', '~> 7.31.3'
  
end
