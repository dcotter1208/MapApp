# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'MapApp' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

pod ‘Firebase’
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'Cloudinary'
pod 'Alamofire', '~> 4.0'
pod 'AlamofireImage', '~> 3.0'
pod ‘Realm’
pod 'RealmSwift', '~> 1.1'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

  # Pods for MapApp

  target 'MapAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MapAppUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
