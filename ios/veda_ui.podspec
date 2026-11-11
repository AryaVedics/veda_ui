Pod::Spec.new do |s|
  s.name             = 'veda_ui'
  s.version          = '0.1.0'
  s.summary          = 'Véda Link on the iPhone.'
  s.description      = 'Shares small feeds between Véda apps through an App Group folder on the phone.'
  s.homepage         = 'https://aryavedics.com'
  s.license          = { :type => 'Proprietary', :text => 'Copyright AryaVedics, LLC' }
  s.author           = { 'AryaVedics' => 'support@aryavedics.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.5'
  s.swift_version    = '5.0'
end
