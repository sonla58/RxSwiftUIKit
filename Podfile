platform :ios, '11.0'
use_frameworks!

workspace 'RxSwiftUIKit.xcworkspace'

def dependencyPod
  pod 'Carbon', '1.0.0-rc.6'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SwiftUIKit_pro', '1.0.0'
end


target 'RxSwiftUIKit' do
  
  project 'RxSwiftUIKit'

  dependencyPod

end

target 'RxSwiftUIKit-Example' do

  project 'RxSwiftUIKit-Example/RxSwiftUIKit-Example'

  dependencyPod

end

