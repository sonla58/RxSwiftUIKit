//
//  ListView.swift
//  RxSwiftUIKit
//
//  Created by finos.son.le on 18/05/2021.
//

import UIKit

import SwiftUIKit_pro
import RxSwift

/// Subclass of `UITableView` support build collectionView by declarative way
public class ListView<Updater: RxSwiftUIKit.Updater>: UITableView {
    
    public typealias SectionBuild = () -> [RxSwiftUIKit.Section]
    
    public let renderer: Renderer<Updater>
    public let sections: SectionBuild
    var reloadTriggers: [Observable<Void>] = []
    
    private var disposeBag = DisposeBag()
    
    static private var defaultRenderer: Renderer<UITableViewUpdater<UITableViewAdapter>> {
        return Renderer(adapter: UITableViewAdapter(), updater: UITableViewUpdater())
    }
    
    /// Required init function to build ListView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - style: provide `UITableView.Style` for ListView
    ///   - sections: a block code to build `Carbon.Section`
    public required init(renderer: Renderer<Updater>,
                  style: UITableView.Style,
                  sections: @escaping SectionBuild) {
        self.renderer = renderer
        self.sections = sections
        
        super.init(frame: .zero, style: style)
        
        setup()
        render()
    }
    
    /// Convenience init function to build ListView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - style: provide `UITableView.Style` for ListView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice ListView reload data. Once one of triggers receive `next` event, ListView will be reload data
    ///   - cells: A block build CellNode
    public convenience init<Cell: CellsBuildable>(
        renderer: Renderer<Updater>,
        style: UITableView.Style,
        reloadTriggers: [Observable<Void>] = [],
        @CellsBuilder cells: @escaping () -> Cell) {
        let sections: SectionBuild = {
            return [RxSwiftUIKit.Section(id: UniqueIdentifier(), cells: cells)]
        }
        self.init(renderer: renderer, style: style, sections: sections)
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build ListView with `Renderer<UITableViewUpdater<UITableViewAdapter>>`
    /// - Parameters:
    ///   - style: provide `UITableView.Style` for ListView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice ListView reload data. Once one of triggers receive `next` event, ListView will be reload data
    ///   - cells: A block build CellNode
    public convenience init<Cell: CellsBuildable>(
        style: UITableView.Style,
        reloadTriggers: [Observable<Void>] = [],
        @CellsBuilder cells: @escaping () -> Cell)
    where Updater == UITableViewUpdater<UITableViewAdapter> {
        let sections: SectionBuild = {
            return [RxSwiftUIKit.Section(id: UniqueIdentifier(), cells: cells)]
        }
        let renderer = Renderer(adapter: UITableViewAdapter(), updater: UITableViewUpdater())
        self.init(renderer: renderer, style: style, sections: sections)
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build ListView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - style: provide `UITableView.Style` for ListView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice ListView reload data. Once one of triggers receive `next` event, ListView will be reload data
    ///   - sections: A block build `Carbon.Section`
    public convenience init(
        renderer: Renderer<Updater>,
        style: UITableView.Style,
        reloadTriggers: [Observable<Void>] = [],
        sections: Section...) {
        self.init(renderer: renderer, style: style, sections: sections)
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build ListView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - style: provide `UITableView.Style` for ListView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice ListView reload data. Once one of triggers receive `next` event, ListView will be reload data
    ///   - sections: A collection of `Carbon.Section`
    public convenience init<C: Collection>(
        renderer: Renderer<Updater>,
        style: UITableView.Style,
        reloadTriggers: [Observable<Void>] = [],
        sections: C) where C.Element == Section? {
        self.init(renderer: renderer, style: style, sections: sections.compactMap { $0 })
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build ListView
    /// - Parameters:
    ///   - renderer: a controller to render passed data to target immediately using specific adapter and updater.
    ///   - style: provide `UITableView.Style` for ListView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice ListView reload data. Once one of triggers receive `next` event, ListView will be reload data
    ///   - sections: A block build a collection of `Carbon.Section`
    public convenience init<S: SectionsBuildable>(
        renderer: Renderer<Updater>,
        style: UITableView.Style,
        reloadTriggers: [Observable<Void>] = [],
        @SectionsBuilder sectionBuilder: () -> S) {
        self.init(renderer: renderer, style: style, sections: sectionBuilder().buildSections())
        self.setTriggers(triggers: reloadTriggers)
    }
    
    /// Convenience init function to build ListView with `Renderer<UITableViewUpdater<UITableViewAdapter>>`
    /// - Parameters:
    ///   - style: provide `UITableView.Style` for ListView
    ///   - reloadTriggers: list of `RxSwift.Observable<Void>` to notice ListView reload data. Once one of triggers receive `next` event, ListView will be reload data
    ///   - sections: A block build a collection of `Carbon.Section`
    public convenience init(style: UITableView.Style, reloadTriggers: [Observable<Void>] = []) where Updater == UITableViewUpdater<UITableViewAdapter> {
        let renderer = Renderer(adapter: UITableViewAdapter(), updater: UITableViewUpdater())
        self.init(renderer: renderer, style: style, sections: [])
        self.setTriggers(triggers: reloadTriggers)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        renderer.target = self as? Updater.Target
    }
    
    public func render() {
        renderer.render(sections())
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

extension Array: SectionsBuildable where Element == Section {
    public func buildSections() -> [Section] {
        return self
    }
}

private struct UniqueIdentifier: Hashable {}
