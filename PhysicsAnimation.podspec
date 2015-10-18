#
# Be sure to run `pod lib lint PhysicsAnimation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PhysicsAnimation"
  s.version          = "0.1.0"
  s.summary          = "A mini library for Physics based animations on the ViewControllers"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
This library provides few classes for Physics based Animations on UIViewController. It automatically adds custom animations on popViewController and pushViewController while pushing and poping ViewControllers from the Navigation Stack. All you to do is set the UINavigationController Delegate.
                       DESC

  s.homepage         = "https://github.com/amol-c/PhysicsAnimation"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "amol-c" => "chaudhari.amol.sopan@gmail.com" }
  s.source           = { :git => "https://github.com/amol-c/PhysicsAnimation.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/@spawn_knight'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PhysicsAnimation' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
