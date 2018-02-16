#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'google_maps'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'GoogleMaps', '~> 2.5.0'
  s.frameworks = "GoogleMaps"
  s.pod_target_xcconfig = {
     'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/**',
     'OTHER_LDFLAGS' => '$(inherited) -undefined dynamic_lookup'
  }
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

