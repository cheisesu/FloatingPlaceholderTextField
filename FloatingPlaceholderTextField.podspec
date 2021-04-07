Pod::Spec.new do |s|
  s.name             = 'FloatingPlaceholderTextField'
  s.version          = '0.1.0'
  s.summary          = 'Text field with animatable moving a placeholder'
  
  s.homepage         = 'https://github.com/cheisesu/FloatingPlaceholderTextField'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitry Shelonin' => 'cheisesu@gmail.com' }
  s.source           = { :git => 'https://github.com/cheisesu/FloatingPlaceholderTextField.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '12.0'
  s.swift_version = '5'
  
  s.source_files = 'Sources/FloatingPlaceholderTextField/Classes/**/*'
  s.frameworks = 'UIKit'
end
