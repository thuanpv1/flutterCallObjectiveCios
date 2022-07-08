Pod::Spec.new do |s|
  s.name         = "SVProgressHUD"
  s.version      = "1.0.0"
  s.summary      = "SVProgressHUD"
  s.description  = <<-DESC
  SVProgressHUD Pods
  DESC
  s.homepage     = "https://macrovideo.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "macrovideo" => "macrovideo.com" }
  
  s.ios.deployment_target = '9.0'
  s.source       = { :git => 'https://macrovideo.com',:tag=>s.version.to_s}
  
  s.subspec 'SVProgressHUD' do |ss|
    ss.source_files = "SVProgressHUD/**/*.{h,m}"
  end
#  s.resource_bundle = {
#    'SVProgressHUD' => ["SVProgressHUD/**/*.{bundle}"]
#  }
  s.resources='SVProgressHUD/**/*.bundle'

end
