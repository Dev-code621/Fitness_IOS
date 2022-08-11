# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'NewTRS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NewTRS
  pod 'Alamofire',                '4.8.2'
  pod 'SnapKit',                  '5.0.1'
  pod 'ObjectMapper',             '3.5.1'
  pod 'SDWebImage',               '5.7.3'
  pod 'GoogleSignIn',             '5.0.2'
  pod 'FBSDKLoginKit',            '7.0.1'
  pod 'Firebase/Analytics',       '7.0.0'
  pod 'Firebase/RemoteConfig',    '7.0.0'
  pod 'Firebase/Crashlytics',     '7.0.0'
  pod 'Firebase/Messaging',       '7.0.0'
  pod 'IQKeyboardManagerSwift',   '6.5.6'
  pod 'BugfenderSDK'
  pod 'google-cast-sdk',          '4.6.1'
  
  target 'NewTRSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NewTRSUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

end
