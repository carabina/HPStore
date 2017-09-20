Pod::Spec.new do |s|

  s.name         = "SimpleStore"
  s.version      = "1.1.1"
  s.summary      = "An lightweight class to perform in-app purchases"

  s.homepage     = "https://facebook.com/HPanhans"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Fri3ndlyGerman" => "contact@henrikpanhans.de" }
  s.social_media_url   = "https://twitter.com/HPanhans"

  s.ios.deployment_target = "8.0"

  s.source       = { :git => 'https://github.com/Fri3ndlyGerman/SimpleStore.git', :tag => "1.1.1" }

  s.source_files = "SimpleStore", "SimpleStore/*.{plist,h,swift}"

  s.requires_arc = true

end
