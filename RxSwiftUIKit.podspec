Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = "RxSwiftUIKit"
  spec.version      = "1.0.0"
  spec.summary      = "RxSwiftUIKit is an extension of [SwiftUIKit](https://github.com/sonla58/SwiftUIKit)"

  spec.description  = <<-DESC
  RxSwiftUIKit is an extension of [SwiftUIKit](https://github.com/sonla58/SwiftUIKit). Combine with [RxSwift](https://github.com/ReactiveX/RxSwift) and [Carbon](https://github.com/ra1028/Carbon), tt gives us the ability to build the tableView or collectionView using the declarative way.
                   DESC

  spec.homepage     = "https://github.com/sonla58/RxSwiftUIKit"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "son.le" => "anhsonleit@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform     = :ios, "11.0"
  spec.swift_version = '5.3'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source       = { :git => "https://github.com/sonla58/RxSwiftUIKit.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files  = "RxSwiftUIKit/**/*.{swift}"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.framework  = "UIKit"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.dependency 'DifferenceKit/Core', "~> 1.1"
  spec.dependency 'RxSwift', '~> 6.1'
  spec.dependency 'RxCocoa', '~> 6.1'
  spec.dependency 'SwiftUIKit_pro', '1.0.0'

end
