Pod::Spec.new do |s|
  s.name            = 'rkBLE'
  s.version         = '0.0.1'
  s.platform        = :ios, '7.0'
  s.license         = { :type => 'MIT', :file => 'LICENSE' }

  s.summary         = "BLE library for iOS. Absolutely easy to use"
  s.homepage        = 'https://github.com/ruiking/ble'
  s.author          = { 'ruiking' => 'support@ruiking.com' }

  s.source          = { :git => 'https://github.com/ruiking/ble.git', :commit => "c63b63323873174754748505426a7e42cb3cfa37" }
  s.source_files    = 'ble-utility/RKBluetooth/**/*.{h,m}'
  s.requires_arc    = true

  s.frameworks      = 'CoreBluetooth'

end
