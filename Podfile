# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'xMexico' do

  platform :ios, '10.2'
  use_frameworks!

  # Pods for xMexico
  
  # Firebase Pods
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Storage'
  pod 'FirebaseUI/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'

end

post_install do |installer|

  installer.pods_project.build_configurations.each do |config|
     config.build_settings.delete('CODE_SIGNING_ALLOWED')
     config.build_settings.delete('CODE_SIGNING_REQUIRED')

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
   
      end
    end
  end
end