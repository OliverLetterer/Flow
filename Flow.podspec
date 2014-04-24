Pod::Spec.new do |spec|
  spec.name         = 'Flow'
  spec.version      = '1.0.0'
  spec.platform     = :ios, '7.0'
  spec.license      = 'MIT'
  spec.source       = { :git => 'https://github.com/OliverLetterer/Flow.git', :tag => spec.version.to_s }
  spec.frameworks   = 'Foundation', 'UIKit', 'AVFoundation'
  spec.requires_arc = true
  spec.homepage     = 'https://github.com/OliverLetterer/Flow'
  spec.summary      = 'Gesture based tutorials inspired by Facebook Paper.'
  spec.author       = { 'Oliver Letterer' => 'oliver.letterer@gmail.com' }
  spec.source_files = 'Flow/*.{h,m}', 'Flow/**/*.{h,m}'
  spec.resources    = "Resources/*.png"
end