Pod::Spec.new do |spec|
  spec.name = "LoopBackSwift"
  spec.version = "0.0.1"
  spec.summary = "A protocol oriented implementation of a Loopback iOS Client based on Swift, this is not a port of official SDK"
  spec.homepage = "https://github.com/Molecularts/loopback-sdk-ios-swift2"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Oscar Anton" => 'oscar@molecularts.com' }
  spec.social_media_url = "https://twitter.com/oscaranton"

  spec.platform = :ios, "8.2"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/Molecularts/loopback-sdk-ios-swift2.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Source/**/*.{h,swift}"

  spec.dependency "Alamofire", "~> 3.4"
  spec.dependency "AlamofireObjectMapper", "~> 3.0"
  spec.dependency "BrightFutures", "~> 4.0"
  spec.dependency "SwiftHTTPStatusCodes", "~> 3.0"

end
