Pod::Spec.new do |s|

  s.name         = "Jay"
  s.version      = "0.1.0"
  s.summary      = "Pure-Swift JSON parser. Linux & OS X ready"

  s.description  = <<-DESC
                  Pure-Swift JSON parser. Linux & OS X ready. Replacement for NSJSONSerialization.
                   DESC

  s.homepage     = "https://github.com/czechboy0/Jay"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Honza Dvorsky" => "https://honzadvorsky.com" }
  s.social_media_url   = "http://twitter.com/czechboy0"

  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/czechboy0/Jay.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/Jay/*.swift"
  
end
