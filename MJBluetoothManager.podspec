Pod::Spec.new do |s|
  s.name             = 'MJBluetoothManager'
  s.version          = '1.0.0'
  s.summary          = 'CoreBluetooth with block-based APIs'
  s.description      = "Simple wrapper around CoreBluetooth that replace delegate based API with block based API"
  s.homepage         = 'https://github.com/mobilejazz/MJBluetoothManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paolo Tagliani' => 'paolo@mobilejazz.com' }
  s.source           = { :git => 'https://github.com/mobilejazz/MJBluetoothManager.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MJBluetoothManager/Classes/**/*'
  s.frameworks = 'CoreBluetooth', 'MapKit'
end
