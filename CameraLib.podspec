
Pod::Spec.new do |s|
  s.name             = 'CameraLib'
  s.version          = '1.6'
  s.summary          = 'Custom Camera (photo & video)with Filters support zoom and flash'
  s.description      = <<-DESC
Custom Camera (photo & video)with Filters support zoom and flash
DESC
 
  s.homepage         = 'https://github.com/sh3at90/CameraEngine.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '<MOHAMED MAHMOUD>' => '<mohamed.sh3t90@gmail.com>' }
  s.source           = { :git => 'https://github.com/sh3at90/CameraEngine.git', :tag => s.version.to_s  }
 
  s.ios.deployment_target = '11.0'
  s.source_files = 'CameraEngine/**/*.{lproj,storyboard,xcdatamodeld,xib,swift}'
 s.resources = 'CameraEngine/**/*.{xcassets,png,json}'
 
end