#
# Be sure to run `pod lib lint mobileSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "mobileSDK"
  s.version          = "0.0.1"
  s.summary          = "A collection of libraries and frameworks supporting the mobile applications."
  s.description      = <<-DESC
                      This is a test description.
                      
                       DESC
  s.homepage         = "https://github.com/1stpaygatewayllc/mobileSDK.git"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "ger.osullivan" => "ger.osullivan@goemerchant.com" }
  s.source           = { :git => "git@github.com:1stpaygatewayllc/mobileSDK.git", :tag => s.version.to_s }
  s.resources        = 'README.md'
  s.xcconfig         = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/**" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  #Networking - AFNetworking
  s.subspec 'Networking' do |net|
    net.preserve_paths = 'Networking/AFNetworking/*.{h,m}', 'Networking/UIKit+AFNetworking/*.{h,m}', 'Networking/*.{h,m}'
    net.source_files   = 'Networking/AFNetworking/*.{h,m}', 'Networking/UIKit+AFNetworking/*.{h,m}', 'Networking/*.{h,m}'
  end

  s.subspec 'Dispatcher' do |dispatcher|
    dispatcher.source_files   = 'Dispatcher/Model/*.{h,m}', 'Dispatcher/*.{h,m}'
  end

end