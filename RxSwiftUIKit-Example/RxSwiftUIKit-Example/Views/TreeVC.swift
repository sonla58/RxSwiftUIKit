//
//  TreeVC.swift
//  RxSwiftUIKit-Example
//
//  Created by finos.son.le on 19/05/2021.
//

import UIKit

import RxSwiftUIKit
import SwiftUIKit_pro
import RxSwift
import RxCocoa
import Carbon

class TreeVC: UI.ViewController {
    
    struct TreeNode {
        let title: String
        let childs: [TreeNode]
    }
    
    var treeNodes: BehaviorRelay<[TreeNode]> = .init(value: [
        TreeNode(title: "Number", childs: {
            Array(0...9).map { (number) -> TreeNode in
                TreeNode(title: "\(number)", childs: [])
            }
        }()),
        TreeNode(title: "Letter", childs: [
            TreeNode(title: "Latin", childs: {
                var letters: [Character] = {
                    let aScalars = "a".unicodeScalars
                    let aCode = aScalars[aScalars.startIndex].value

                    return (0..<26).map {
                        i in Character(UnicodeScalar(aCode + i)!)
                    }
                }()
                return letters.map { (char) -> TreeNode in
                    TreeNode(title: "\(char)", childs: [])
                }
            }()),
            TreeNode(title: "Vietnamese", childs: {
                let str = "ăâđêôơư"
                return str.map { (char) -> TreeNode in
                    TreeNode(title: "\(char)", childs: [])
                }
            }())
        ])
    ])
    
    func getFlatTree(initLevel: Int, treeNodes: [TreeNode], expandState: [String: Bool]) -> [(level: Int, node: TreeNode)] {
        var results: [(level: Int, node: TreeNode)] = []
        results = treeNodes.reduce(into: [(level: Int, node: TreeNode)]()) { (seed, nextNode) in
            seed.append((level: initLevel, node: nextNode))
            if expandState[nextNode.title] == true {
                seed += self.getFlatTree(initLevel: initLevel + 1, treeNodes: nextNode.childs, expandState: expandState)
            }
        }
        return results
    }
    
    var expandState: BehaviorRelay<[String: Bool]> = .init(value: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.title = "Tree View"
        self.navigationController?.navigationBar.sizeToFit()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Collapse", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.collapseAll))
    }
    
    override var subviewsLayout: SomeView {
        ListView.init(style: .plain, reloadTriggers: [
            self.treeNodes.void(),
            self.expandState.void()
        ]) {
            
            InstanceComponent(identifier: 9999) { (_) in
                ZStackView {
                    UILabel()
                        .dx.text("This demo is show you ListView can reload with data source by a reactive way. Check `TreeVC` class for more infomation")
                        .dx.font(UIFont.systemFont(ofSize: 14, weight: .regular))
                        .dx.numberOfLines(0)
                        .dx.textAlignment(NSTextAlignment.center)
                        .stickingToParentEdges(left: 16, right: 16, top: 14, bottom: 14)
                }
                .dx.style(SimpleCard())
                .fillingParent(insets: (22, 22, 14, 14))
            }
            
            Group(of: self.getFlatTree(initLevel: 0, treeNodes: self.treeNodes.value, expandState: self.expandState.value)) { (level: Int, node: TreeNode) in
                TreeComponent(title: node.title, level: level) { [weak self] in
                    let currentState = self?.expandState.value[node.title] ?? false
                    var value = self?.expandState.value ?? [:]
                    value[node.title] = !currentState
                    self?.expandState.accept(value)
                }
            }
        }
        .fillingParent()
    }
    
    @objc private func collapseAll() {
        self.expandState.accept([:])
    }
}

class TreeCell: UI.View {
    
    private var leftMargin: NSLayoutConstraint?
    var lbTitle: UILabel?
    var onTap: () -> Void = { }
    
    private var disposeBag = DisposeBag()
    
    override var subviewsLayout: SomeView {
        ZStackView {
            UILabel()
                .dx.storeReference(refStore: &lbTitle)
                .stickingToParentEdges(left: nil, right: .greaterThanOrEqualTo(20), top: 12, bottom: 12)
                .layout { [weak self] (parent, node, revertable) in
                    self?.leftMargin = node.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 20)
                    self?.leftMargin?.isActive = true
                    revertable.append(BlockRevertable({ [weak self] in
                        self?.leftMargin?.isActive = false
                    }))
                }
            UIButton()
                .dx.useRx(withUnretained: self, disposeBag: disposeBag, reactiveBlock: { (owner, btn: UIButton) -> [Disposable] in
                    btn.rx.tap.bind { (_) in
                        owner.onTap()
                    }
                })
                .fillingParent()
        }
        .fillingParent()
    }
    
    func updateLeftMargin(constant: CGFloat) {
        leftMargin?.constant = constant
        self.layoutIfNeeded()
    }
}

struct TreeComponent: IdentifiableComponent {
    var id: String {
        return title
    }
    
    var title: String
    var level: Int
    var onTap: () -> Void
    
    func renderContent() -> TreeCell {
        return TreeCell()
    }
    
    func render(in content: TreeCell) {
        content.lbTitle?.text = title
        content.onTap = onTap
        content.updateLeftMargin(constant: CGFloat(20 + (level * 16)))
    }
}

extension ObservableType {
    func void() -> Observable<Void> {
        map { _ in Void() }
    }
}
