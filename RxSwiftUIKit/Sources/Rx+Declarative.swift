//
//  Rx+Declarative.swift
//  RxSwiftUIKit
//
//  Created by finos.son.le on 19/05/2021.
//

import SwiftUIKit_pro
import RxSwift

extension Declarative where Base: ReactiveCompatible {
    
    /// Provide a declarative way to add rx code to element
    /// - Parameters:
    ///   - owner: Retain object
    ///   - disposeBag: disposeBag to add rx code
    ///   - reactiveBlock: block reactive code
    /// - Returns: return base
    public func useRx<Object: AnyObject>(withUnretained owner: Object,
                                  disposeBag: DisposeBag,
                                  @DisposeBag.DisposableBuilder reactiveBlock: (_ owner: Object, _ base: Base) -> [Disposable]) -> Base {
        disposeBag.insert(
            reactiveBlock(owner, base)
        )
        return base
    }
    
    /// Provide a declarative way to add rx code to element
    /// - Parameters:
    ///   - disposeBag: disposeBag to add rx code, default `nil`
    ///   - reactiveBlock: block reactive code
    /// - Returns: return base
    public func useRx(disposeBag: DisposeBag? = nil, @DisposeBag.DisposableBuilder reactiveBlock: (_ base: Base) -> [Disposable]) -> Base {
        let disposable = reactiveBlock(base)
        disposeBag?.insert(disposable)
        return base
    }
}
