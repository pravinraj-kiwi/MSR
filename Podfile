# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
def main_pods
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # Pods for Contributor
  pod 'Alamofire', '~> 4.7'
#  pod 'RealmSwift'
  pod 'SnapKit'
  pod 'IGListKit'
  pod 'Moya'
  pod 'KeychainSwift'
  pod 'SwiftyUserDefaults', '~> 4.0'
  pod 'AZTabBar'
  pod 'SwiftyAttributes'
  pod 'ScrollingStackViewController'
  pod 'ObjectMapper'
  pod 'Moya-ObjectMapper'
  pod 'EmailValidator'
  pod 'CCTemplate'
  pod 'SwiftSoup'
  pod 'Kingfisher'
  pod 'DateToolsSwift'
  pod 'Toast-Swift'
  pod 'URLNavigator'
  pod 'SwiftyJSON'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Cosmos'
  pod 'AMPopTip'
  pod 'UIColor_Hex_Swift'
  pod 'PhoneNumberKit'
  pod 'IQKeyboardManagerSwift'
  pod 'CryptoSwift'
  pod 'SwiftNIO'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
 #pod ‘FBSDKGamingServiceKit’, ‘~> 8.0.0’
 #pod 'Pulsator'
  pod 'DynamicCodable'
  pod 'UICountingLabel'
  pod 'Instructions'
  pod 'AWSS3'
  pod 'AAViewAnimator'
  pod 'AFDateHelper'
  pod 'SDWebImagePDFCoder'
  # Firebase
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Crashlytics'
  pod 'netfox'
  pod 'TwitterKit5', :inhibit_warnings => true

  # AppsFlyer
  pod 'AppsFlyerFramework'
end

target 'Contributor' do
  
  main_pods
  
  target 'ContributorTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ContributorUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'MSRJobWidget Staging 2' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'MSRJobWidget' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Contributor Staging' do
  main_pods
end

target 'Contributor Staging 2' do
  main_pods
end

target 'Contributor Local' do
  main_pods
end

post_install do | installer |
  installer.pods_project.targets.each do |target|
    if ['Alamofire', 'Result', 'Toast-Swift', 'Cosmos', 'AMPopTip', 'Moya', 'Moya-ObjectMapper'].include? "#{target}"
      print "Setting #{target}'s SWIFT_VERSION to 4.2\n"
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end

#    target.build_configurations.each do |config|
#      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#    end

  end
end
