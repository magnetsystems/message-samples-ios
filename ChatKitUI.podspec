Pod::Spec.new do |s|
  s.name               =  'ChatKitUI'
  s.version            =  '0.0.0'
  s.license            =  { :type => 'Apache 2.0' }
  s.summary            =  'iOS framework for developing apps using the Magnet Message platform.'
  s.description        =  'Magnet Message is a powerful, open source mobile messaging framework enabling real-time user engagement for your mobile apps. Send relevant and targeted communications to customers or employees. Enhance your mobile app with actionable notifications, alerts, in-app events, two-way interactions and more. Get started and get coding in minutes!'
  s.homepage           =  'https://www.magnet.com/developer/magnet-message/'
  s.author             =  { 'Magnet Systems, Inc.' => 'support@magnet.com' }
  s.source             =  { :git => 'https://github.com/magnetsystems/message-samples-ios.git', :branch => "ChatKit" }

  s.platform = :ios, '8.0'
  s.requires_arc = true

  s.resources = ['ChatKit/source/**/*.{xib,storyboard,bundle,png}']

  s.source_files = 'ChatKit/source/**/*.{h,m,swift}'

  s.frameworks = 'QuartzCore', 'CoreGraphics', 'CoreLocation', 'MapKit', 'UIKit', 'Foundation', 'AudioToolbox'

  s.xcconfig       =  { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-ObjC', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES','ENABLE_BITCODE' => 'NO'}

  s.dependency 'MagnetMax', '~> 2.5.1'
  s.dependency 'NYTPhotoViewer' , '~> 1.1.0'
  s.dependency 'DZVideoPlayerViewController'

end

