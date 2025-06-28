# Uncomment the next line to define a global platform for your project
# platform :ios, '12.0'

target 'Financial Ratios Go' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Finiance Ratio Calculator
  pod 'IQKeyboardManager', '~> 6.2.1'
  pod 'SnapKit', '~> 5.0.0'
  pod 'EFCountingLabel'
  pod 'Kingfisher'
  pod "SkeletonView"
  pod 'Google-Mobile-Ads-SDK'
  pod 'MBProgressHUD'
  pod 'Then'
  pod 'Toast-Swift'

end



post_install do |installer|

    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end

    installer.pods_project.targets.each do |target|
        if target.name.start_with?("Pods")
            puts "Updating #{target.name} OTHER_LDFLAGS to OTHER_LDFLAGS[sdk=iphone*]"
            target.build_configurations.each do |config|
                xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                new_xcconfig = xcconfig.sub('OTHER_LDFLAGS =', 'OTHER_LDFLAGS[sdk=iphone*] =')
                File.open(xcconfig_path, "w") { |file| file << new_xcconfig }
            end
        end
    end
end
