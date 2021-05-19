//
//  GridView.swift
//  RxSwiftUIKit
//
//  Created by finos.son.le on 19/05/2021.
//

import UIKit

import SwiftUIKit_pro
import Carbon
import RxSwift

/// Subclass of `UICollectionView` support build collectionView by declarative way
public class GridView<Updater: Carbon.Updater>: UICollectionView where Updater.Adapter: UICollectionViewAdapter {
    
    public typealias SectionBuild = () -> [Carbon.Section]
    
    public let renderer: Renderer<Updater>
    public let sections: SectionBuild
    var reloadTriggers: [Observable<Void>] = []
    
    private var disposeBag = DisposeBag()
    
    static private var defaultRenderer: Renderer<UICollectionViewUpdater<UICollectionViewFlowLayoutAdapter>> {
        return Renderer(
            adapter: UICollectionViewFlowLayoutAdapter(),
            updater: UICollectionViewUpdater()
        )
    }
    
    /// Required init function to build GridView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - collectionViewLayout: provide `UICollectionViewLayout` to layout collectionView
    ///   - sections: a block code to build `Carbon.Section`
    public required init(renderer: Renderer<Updater>,
                         collectionViewLayout: UICollectionViewLayout,
                         sections: @escaping SectionBuild) {
        self.renderer = renderer
        self.sections = sections
        
        super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        setup()
        render()
    }
    
    /// Convenience init function to build GridView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - collectionViewLayout: provide `UICollectionViewLayout` to layout collectionView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice GridView reload data. Once one of triggers receive `next` event, GridView will be reload data
    ///   - cells: A block build CellNode
    public convenience init<Cell: CellsBuildable>(
        renderer: Renderer<Updater>,
        collectionViewLayout: UICollectionViewLayout,
        reloadTriggers: [Observable<Void>] = [],
        @CellsBuilder cells: @escaping () -> Cell) {
        let sections: SectionBuild = {
            return [Carbon.Section(id: UniqueIdentifier(), cells: cells)]
        }
        self.init(renderer: renderer, collectionViewLayout: collectionViewLayout, sections: sections)
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build GridView with `Renderer<UICollectionViewUpdater<UICollectionViewFlowLayoutAdapter>>` and `UICollectionViewFlowLayout`
    /// - Parameters:
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice GridView reload data. Once one of triggers receive `next` event, GridView will be reload data
    ///   - cells: A block build CellNode
    public convenience init<Cell: CellsBuildable>(
        reloadTriggers: [Observable<Void>] = [],
        @CellsBuilder cells: @escaping () -> Cell
    ) where Updater == UICollectionViewUpdater<UICollectionViewFlowLayoutAdapter> {
        let sections: SectionBuild = {
            return [Carbon.Section(id: UniqueIdentifier(), cells: cells)]
        }
        let renderer = Renderer(adapter: UICollectionViewFlowLayoutAdapter(), updater: UICollectionViewUpdater())
        self.init(renderer: renderer, collectionViewLayout: UICollectionViewFlowLayout(), sections: sections)
        self.setTriggers(triggers: reloadTriggers)
    }
    
    
    /// Convenience init function to build GridView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - collectionViewLayout: provide `UICollectionViewLayout` to layout collectionView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice GridView reload data. Once one of triggers receive `next` event, GridView will be reload data
    ///   - sections: A block build `Carbon.Section`
    public convenience init(
        renderer: Renderer<Updater>,
        collectionViewLayout: UICollectionViewLayout,
        reloadTriggers: [Observable<Void>],
        sections: Section...
    ) {
        self.init(renderer: renderer, collectionViewLayout: collectionViewLayout, sections: { sections })
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build GridView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - collectionViewLayout: provide `UICollectionViewLayout` to layout collectionView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice GridView reload data. Once one of triggers receive `next` event, GridView will be reload data
    ///   - sections: A collection of `Carbon.Section`
    public convenience init<C: Collection>(
        renderer: Renderer<Updater>,
        collectionViewLayout: UICollectionViewLayout,
        reloadTriggers: [Observable<Void>],
        sections: C
    ) where C.Element == Section? {
        self.init(renderer: renderer, collectionViewLayout: collectionViewLayout, sections: { sections.compactMap { $0 } })
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build GridView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - collectionViewLayout: provide `UICollectionViewLayout` to layout collectionView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice GridView reload data. Once one of triggers receive `next` event, GridView will be reload data
    ///   - sections: A block build `Carbon.Section`
    public convenience init<S: SectionsBuildable>(
        renderer: Renderer<Updater>,
        collectionViewLayout: UICollectionViewLayout,
        reloadTriggers: [Observable<Void>] = [],
        @SectionsBuilder sectionBuilder: @escaping () -> S
    ) {
        self.init(renderer: renderer, collectionViewLayout: collectionViewLayout, sections: {
            sectionBuilder().buildSections()
        })
        self.setTriggers(triggers: reloadTriggers)
    }

    
    /// Convenience init function to build GridView with `Renderer<UICollectionViewUpdater<UICollectionViewFlowLayoutAdapter>>` and `UICollectionViewFlowLayout`
    /// - Parameters:
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice GridView reload data. Once one of triggers receive `next` event, GridView will be reload data
    ///   - sectionBuilder: A block build a collection of `Carbon.Section`
    public convenience init<S: SectionsBuildable>(
        reloadTriggers: [Observable<Void>] = [],
        @SectionsBuilder sectionBuilder: @escaping () -> S
    ) where Updater == UICollectionViewUpdater<UICollectionViewFlowLayoutAdapter> {
        let renderer = Renderer(adapter: UICollectionViewFlowLayoutAdapter(), updater: UICollectionViewUpdater())
        self.init(renderer: renderer, collectionViewLayout: UICollectionViewFlowLayout(), sections: {
            sectionBuilder().buildSections()
        })
        self.setTriggers(triggers: reloadTriggers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = UIColor.systemBackground
        } else {
            self.backgroundColor = .white
        }
        renderer.target = self as? Updater.Target
    }
    
    public func render() {
        let _sections = sections()
        renderer.render(_sections)
    }
    
    private func setTriggers(triggers: [Observable<Void>]) {
        self.reloadTriggers = triggers
        
        Observable.merge(triggers)
            .debounce(.milliseconds(100), scheduler: MainScheduler())
            .subscribe { [weak self] (_) in
                self?.render()
            } onError: { (_) in
                //
            } onCompleted: {
                //
            } onDisposed: {
                //
            }
            .disposed(by: disposeBag)
    }
}

private struct UniqueIdentifier: Hashable {}
