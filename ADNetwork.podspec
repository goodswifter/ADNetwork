Pod::Spec.new do |s|
  s.name             = 'ADNetwork'
  s.version          = '0.1.0'
  s.summary          = 'ADNetwork.'
  s.description      = 'ADNetwork description'

  s.homepage         = 'https://github.com/goodswifter/ADNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'goodswifter' => '1042480866@qq.com' }
  s.source           = { :git => 'https://github.com/goodswifter/ADNetwork.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'ADNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ADNetwork' => ['ADNetwork/Assets/*.png']
  # }
  
  s.dependency 'YTKNetwork'
  s.dependency 'ADProgressHUD'
end
