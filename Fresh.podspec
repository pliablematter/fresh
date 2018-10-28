#
# Be sure to run `pod lib lint Fresh.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Fresh'
  s.version          = '1.2.0'
  s.summary          = 'Keeps content up-to-date in your iOS app'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                      Fresh is a library that keeps your iOS application's content up-to-date without running your own web application and server. Just host your content on Amazon S3 or any standards-compliant web server and you're ready to go.
                      DESC

  s.homepage         = 'https://github.com/doug@pliablematter.com/Fresh'
  # s.screenshots     = 'www.example.com/screenshots_1',  www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pliable Matter' => 'info@pliablematter.com' }
  s.source           = { :git => 'https://github.com/pliablematter/Fresh.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/pliablematter'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Fresh/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Fresh' => ['Fresh/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency 'tarkit', '~> 0.1.3'
end
