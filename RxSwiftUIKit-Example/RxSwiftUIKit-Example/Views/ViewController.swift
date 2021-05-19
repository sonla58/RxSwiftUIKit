//
//  ViewController.swift
//  RxSwiftUIKit-Example
//
//  Created by finos.son.le on 18/05/2021.
//

import UIKit

import RxSwiftUIKit
import SwiftUIKit_pro
import RxSwift
import RxCocoa

class ViewController: UI.ViewController {
    
    typealias Item = (String, () -> Void)
    
    lazy var items: BehaviorRelay<[Item]> = .init(
        value: [
            ("Tree list with ListView", {
                let vc = TreeVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            ("Number game with GridView", {
                let vc = GridGame()
                self.navigationController?.pushViewController(vc, animated: true)
            })
        ])
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.title = "RxSwiftUIKit"
        self.navigationController?.navigationBar.sizeToFit()
    }

    override var subviewsLayout: SomeView {
        ListView(style: .plain, reloadTriggers: [self.items.map { _ in Void() }]) {
            InstanceComponent(identifier: 0) { (_) in
                ZStackView {
                    UILabel()
                        .dx.text("This screen was build by `InstanceComponent` in `ListView`. Check `ViewController` class for more infomation.")
                        .dx.font(UIFont.systemFont(ofSize: 14, weight: .regular))
                        .dx.numberOfLines(0)
                        .dx.textAlignment(NSTextAlignment.center)
                        .stickingToParentEdges(left: 16, right: 16, top: 14, bottom: 14)
                }
                .dx.style(SimpleCard())
                .fillingParent(insets: (22, 22, 14, 14))
            }
            
            Group(of: self.items.value) { (item: Item) in
                InstanceComponent(identifier: item.0) { (i) in
                    ZStackView {
                        UILabel()
                            .dx.text(i)
                            .stickingToParentEdges(left: 20, right: .greaterThanOrEqualTo(20), top: 12, bottom: 12)
                        UIButton()
                            .dx.useRx(withUnretained: self, disposeBag: self.disposeBag, reactiveBlock: { (owner, base: UIButton) in
                                base.rx.tap
                                    .bind { (_) in
                                        item.1()
                                    }
                            })
                            .fillingParent()
                    }
                    .fillingParent()
                }
            }
            
        }
        .fillingParent()
    }

}

struct SimpleCard<CardView: UIView>: Stylable {
    
    func style(_ base: CardView) {
        if #available(iOS 13.0, *) {
            base.backgroundColor = .secondarySystemBackground
        } else {
            base.backgroundColor = .gray
        }
        base.layer.cornerRadius = 16
    }
    
}
