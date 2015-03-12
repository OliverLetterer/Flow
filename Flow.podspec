Pod::Spec.new do |spec|
  spec.name         = 'Flow'
  spec.version      = '1.6.0'
  spec.platform     = :ios, '7.0'
  spec.license      = 'MIT'
  spec.source       = { :git => 'https://github.com/OliverLetterer/Flow.git', :tag => spec.version.to_s }
  spec.frameworks   = 'Foundation', 'UIKit', 'AVFoundation'
  spec.requires_arc = true
  spec.homepage     = 'https://github.com/OliverLetterer/Flow'
  spec.summary      = 'Tutorial framework for gesture driven UIs, Facebook Paper style.'
  spec.author       = { 'Oliver Letterer' => 'oliver.letterer@gmail.com' }
  spec.social_media_url = 'https://twitter.com/oletterer'

  spec.resources    = "Resources/*.png"
  spec.private_header_files = 'Flow/Private/*.h'
  spec.source_files = 'Flow/*.{h,m}', 'Flow/**/*.{h,m}'
end
