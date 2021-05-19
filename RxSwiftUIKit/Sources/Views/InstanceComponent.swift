//
//  InstanceComponent.swift
//  RxSwiftUIKit
//
//  Created by finos.son.le on 19/05/2021.
//

import UIKit

import SwiftUIKit_pro
import Carbon
import RxSwift

public struct InstanceComponent<Diff: Hashable>: IdentifiableComponent {
    public var id: Diff
    var layouts: [SomeView]
    var size: (_ bound: CGRect) -> CGSize?
    
    public init(identifier: Diff, size: CGSize? = nil, layouts: [SomeView]) {
        self.layouts = layouts
        self.id = identifier
        self.size = { _ in return size }
    }
    
    public init(identifier: Diff, size: @escaping (_ bound: CGRect) -> CGSize? = { _ in nil }, @LayoutBuilder layoutBuilder: (Diff) -> [SomeView]) {
        self.id = identifier
        self.layouts = layoutBuilder(identifier)
        self.size = size
    }
    
    public func renderContent() -> InstanceCell {
        return InstanceCell(group(layouts))
    }
    
    public func render(in content: InstanceCell) {
        content.layout = group(layouts)
        content.render()
    }
    
    public func referenceSize(in bounds: CGRect) -> CGSize? {
        size(bounds)
    }
}

public class InstanceCell: UIView {
    
    var layout: SomeView
    
    var layoutBag = LayoutBag()
    
    public required init(_ layout: SomeView) {
        self.layout = layout
        
        super.init(frame: .zero)
        
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        render()
    }
    
    public func render() {
        for v in self.subviews{
           v.removeFromSuperview()
        }
        layout.layout(in: self)
    }
}
