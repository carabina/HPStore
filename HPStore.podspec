Pod::Spec.new do |s|

  s.name         = "HPStore"
  s.version      = "1.2.1"
  s.summary      = "A lightweight Swift wrapper to make In-App purchases"
  s.description  = "SimpleStore is a leightweight framework built on top of Apple's StoreKit to perform in-app purchases. It takes pretty much all the work from you so that you can focus on your own code."
  s.homepage     = "https://github.com/Fri3ndlyGerman/HPStore"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Henrik Panhans" => "henrikpanhans@icloud.com" }
  s.social_media_url   = "http://twitter.com/HPanhans"
  s.platform     = :ios
  s.ios.deployment_target = "10.0"
  
  s.source       = { :git => "https://github.com/Fri3ndlyGerman/HPStore.git", :tag => "#{s.version}" }
  s.source_files  = "HPStore", "HPStore/**/*.{swift}"
  s.requires_arc = true
  s.dependency 'SwiftyReceiptValidator'

end
