Pod::Spec.new do |s|
    s.name         = "NVSDK"
    s.version      = "1.0.0"
    s.summary      = "NVSDK"
    s.description  = <<-DESC
                     NVSDK Pods
                     DESC
    s.homepage     = "https://macrovideo.com"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = { "macrovideo" => "macrovideo.com" }

    s.pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '-ObjC',
      'ENABLE_BITCODE' => 'NO',
     }
    
    s.ios.deployment_target = '9.0'
    s.source       = { :git => 'https://macrovideo.com',:tag=>s.version.to_s}
  
    s.subspec 'NVSDK' do |ss|
      ss.source_files = "NVSDK/**/*.{h,m}"
      
    end
   s.vendored_libraries  = "NVSDK/*.a"
   
end
