#
# Be sure to run `pod lib lint BackendServiceAdapter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BackendServiceAdapter'
  s.version          = '0.3.0'
  s.summary          = 'A short description of BackendServiceAdapter.'

  s.swift_version = '4.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/7946b191437a3fa5083fec69131c92a7b428824d/BackendServiceAdapter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '7946b191437a3fa5083fec69131c92a7b428824d' => 'dusan.cucurevic@quantox.com' }
  s.source           = { :git => 'https://github.com/dusanIntellex/backend-operation-layer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'BackendServiceAdapter/Classes/**/*'
  
  # Remove when implement firebase
  s.exclude_files = 'BackendServiceAdapter/Classes/**/BackendFirebaseExecutor.swift'
  
  # s.resource_bundles = {
  #   'BackendServiceAdapter' => ['BackendServiceAdapter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Alamofire', '~> 4.5'
   s.dependency 'Kingfisher', '~> 4.1'
   s.dependency 'RxSwift', '~> 4.3'
   
end
