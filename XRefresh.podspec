

Pod::Spec.new do |s|

  s.name         = "XRefresh"
  s.version      = "1.1.1"
  s.summary      = "一个简单易用的下拉刷新，上拉加载iOS控件"


  s.description  = <<-DESC
XRfresh
pull up
pull down
                   DESC

  s.homepage     = "http://github.com/xjydev/XRefresh"


  s.license      = "MIT"

  s.author             = { "XIAO" => "xjydev@163.com" }

  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/xjydev/XRefresh.git", :tag => "#{s.version}" }


  s.source_files  = "class/XRefresh.{h,m}"
  #s.exclude_files = ""

  s.public_header_files = "class/XRefresh.h"


   s.frameworks = "UIKit", "Foundation"



  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
