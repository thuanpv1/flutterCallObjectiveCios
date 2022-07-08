Pod::Spec.new do |s|
    s.name         = "ALAssetsLibrary"
    s.version      = "1.0.0"
    s.summary      = "ALAssetsLibrary"
    s.description  = <<-DESC
                         ALAssetsLibrary Pods
                     DESC
    s.homepage     = "https://macrovideo.com"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = { "macrovideo" => "macrovideo.com" }
    
    s.ios.deployment_target = '9.0'
    s.source       = { :git => 'https://macrovideo.com',:tag=>s.version.to_s}
    
    s.subspec 'ALAssetsLibrary' do |ss|
      ss.source_files = "ALAssetsLibrary/**/*.{h,m}"
    end
end
