#
# Be sure to run `pod lib lint YCCardView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YCCardView'
  s.version          = '0.0.4'
  s.summary          = 'YCCardView 左滑右滑卡片框架'
  s.description      = 'YCCardView 左滑右滑卡片框架,支持自定义卡片视图等众多功能！'
  s.homepage         = 'https://github.com/Rycccccccc/YCCardView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rycccccccc' => '787725121@qq.com' }
  s.source           = { :git => 'https://github.com/Rycccccccc/YCCardView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'YCCardView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YCCardView' => ['YCCardView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
