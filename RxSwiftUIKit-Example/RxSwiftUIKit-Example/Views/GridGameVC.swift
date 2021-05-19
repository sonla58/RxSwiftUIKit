//
//  GridGameVC.swift
//  RxSwiftUIKit-Example
//
//  Created by finos.son.le on 19/05/2021.
//

import UIKit

import RxSwiftUIKit
import SwiftUIKit_pro
import RxSwift
import RxCocoa

class GridGame: UI.ViewController {
    
    let itemSize = 40
    var items: BehaviorRelay<[Int]> = .init(value: [])
    
    let currentNumber: BehaviorRelay<Int> = .init(value: 0)
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentNumber
            .withUnretained(self)
            .map { (owner, i) -> [Int] in
                let max = owner.getMaxNumber() + i - 1
                return owner.renderItem(start: i, max: max)
            }
            .bind(to: items)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.title = "Number game"
        self.navigationController?.navigationBar.sizeToFit()
    }
    
    override var subviewsLayout: SomeView {
        GridView(reloadTriggers: [
            self.currentNumber.void(),
            self.items.void()
        ]) {
            Section(id: 0) {
                InstanceComponent(identifier: 9999) { (bound) -> CGSize? in
                    return CGSize(width: bound.size.width, height: 100)
                } layoutBuilder: { (_) -> [SomeView] in
                    ZStackView {
                        UILabel()
                            .dx.text("Find Number: \(self.currentNumber.value)")
                            .dx.font(UIFont.systemFont(ofSize: 15, weight: .bold))
                            .dx.numberOfLines(0)
                            .dx.textAlignment(NSTextAlignment.center)
                            .stickingToParentEdges(left: 16, right: 16, top: 14, bottom: 14)
                    }
                    .dx.style(SimpleCard())
                    .fillingParent(insets: (22, 22, 14, 14), relativeToSafeArea: true)
                }
            }
            Section(id: 2) {
                Group(of: self.items.value) { (item) in
                    InstanceComponent(identifier: item) { (bound) -> CGSize? in
                        return CGSize(width: self.itemSize, height: self.itemSize)
                    } layoutBuilder: { (_) -> [SomeView] in
                        ZStackView {
                            UILabel()
                                .dx.text("\(item)")
                                .centeringInParent()
                            UIButton()
                                .dx.useRx(withUnretained: self, disposeBag: self.disposeBag, reactiveBlock: { (owner: GridGame, btn: UIButton) -> [Disposable] in
                                    btn.rx.tap
                                        .bind { [owner] (_) in
                                            if owner.currentNumber.value == item {
                                                owner.currentNumber.accept(item + 1)
                                            }
                                        }
                                })
                                .fillingParent()
                        }
                        .fillingParent()
                    }

                }
            }
        }
        .dx.style({ (v) in
            if let layout = v.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
            }
        })
        .fillingParent()
    }
    
    private func getMaxColume() -> Int {
        let width = UIScreen.main.bounds.width
        return (Int(width) / itemSize)
    }
    
    private func getMaxRow() -> Int {
        let height = UIScreen.main.bounds.height - 300
        return (Int(height) / itemSize)
    }
    
    private func getMaxNumber() -> Int {
        let colume = getMaxColume()
        let row = getMaxRow()
        return colume * row
    }
    
    private func renderItem(start: Int, max: Int) -> [Int] {
        return Array(start...max).shuffled()
    }
}
