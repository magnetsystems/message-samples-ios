Pod::Spec.new do |s|
  s.name               =  'ChatKit'
  s.version            =  '1.3.3'
  s.license            =  { :type => 'Apache 2.0' }
  s.summary            =  'iOS framework for developing apps using the Magnet Message platform.'
  s.description        =  'Magnet Message is a powerful, open source mobile messaging framework enabling real-time user engagement for your mobile apps. Send relevant and targeted communications to customers or employees. Enhance your mobile app with actionable notifications, alerts, in-app events, two-way interactions and more. Get started and get coding in minutes!'
  s.homepage           =  'https://www.magnet.com/developer/magnet-message/'
  s.author             =  { 'Magnet Systems, Inc.' => 'support@magnet.com' }
  #s.source             =  { :git => 'https://github.com/magnetsystems/message-samples-ios.git', :branch => "ChatKit" }
  s.source             =  { :git => 'https://github.com/magnetsystems/message-samples-ios.git', :tag => "tag-chatkit-#{s.version}" }
  s.platform = :ios, '8.0'
  s.requires_arc = true

  s.resources = ['ChatKit/source/**/*.{xib,storyboard,bundle,png}']

  

  s.frameworks = 'QuartzCore', 'CoreGraphics', 'CoreLocation', 'MapKit', 'UIKit', 'Foundation', 'AudioToolbox'

  s.xcconfig       =  { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-ObjC', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES','ENABLE_BITCODE' => 'NO'}

  s.subspec 'UI_Core' do |ss|
    ss.source_files = ['ChatKit/source/src/**/*.{h,m,swift}','ChatKit/source/Views/**/*.{h,m,swift}']
    ss.dependency 'MagnetMax', '~> 2.5.3'
    ss.dependency 'NYTPhotoViewer' , '~> 1.1.0'
    ss.dependency 'DZVideoPlayerViewController'
    ss.dependency 'CocoaLumberjack/Swift'
  end

  s.subspec 'Public' do |ss|
    ss.source_files = 'ChatKit/source/ChatKit/**/*.{h,m,swift}'
    ss.dependency 'ChatKit/UI_Core', '~> 1.3.3'
  end
end