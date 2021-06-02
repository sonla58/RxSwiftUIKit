platform :ios, '11.0'
use_frameworks!

workspace 'RxSwiftUIKit.xcworkspace'

def dependencyPod
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SwiftUIKit_pro', '~> 1.1.0'
  pod 'DifferenceKit/Core', '~> 1.1'
end


target 'RxSwiftUIKit' do
  
  project 'RxSwiftUIKit'

  dependencyPod

end

target 'RxSwiftUIKit-Example' do

  project 'RxSwiftUIKit-Example/RxSwiftUIKit-Example'

  dependencyPod

end

