#
#  Be sure to run `pod spec lint PMFresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "PMFresh"
  s.version      = "1.0.0"
  s.summary      = "Keeps content up-to-date in your iOS app"

  s.description  = <<-DESC
                   Fresh is a library that keeps your iOS application's content up-to-date without running your own web application and server. Just host your content on Amazon S3 or any standards-compliant web server and you're ready to go.
                   DESC

  s.homepage     = "https://github.com/pliablematter/fresh"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.authors = 'Doug Burns'
  s.social_media_url   = "http://twitter.com/pliablematter"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/pliablematter/fresh.git", :tag => "1.0.0" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Classes", "PMFreshLibrary/**/*.{h,m}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  s.platform = :ios
  
  s.dependency 'tarkit', '~> 0.1.3'
end
