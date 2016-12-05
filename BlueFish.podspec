Pod::Spec.new do |s|
  s.name             = 'BlueFish'
  s.version          = '1.0.1'
  s.summary          = 'CoreBluetooth with block-based APIs'
  s.description      = "Simple wrapper around CoreBluetooth that replace delegate based API with block based API"
  s.homepage         = 'https://github.com/mobilejazz/BlueFish'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Paolo Tagliani' => 'paolo@mobilejazz.com' }
  s.source           = { :git => 'https://github.com/mobilejazz/BlueFish.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'BlueFish/Classes/**/*'
  s.frameworks = 'CoreBluetooth', 'MapKit'
end
