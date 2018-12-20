//
//  PasswordViewController.swift
//  Form
//
//  Created by iSXQ on 2018/12/16.
//  Copyright © 2018 isxq. All rights reserved.
//

import UIKit

final class TargetAction {
    let excute: ()->Void
    init(_ excute: @escaping ()->Void) {
        self.excute = excute
    }
    
    @objc func action(_ sender: Any) {
        excute()
    }
}

struct Observer<State> {
    var strongRefrences: [Any]
    var update: (State) -> Void
    
}

struct RenderingContext<State> {
    let state: State
    let change: ((inout State)->Void)-> Void
    let pushViewController: (UIViewController) -> Void
    let popViewController: () -> Void
}

class FormDriver<State> {
    var formViewController: FormViewController!
    var sections: [Section] = []
    var observer: Observer<State>!
    
    init(initial state: State, build: (RenderingContext<State>) -> ([Section], Observer<State>)) {
        self.state = state
        let context = RenderingContext(state: state, change: { [unowned self] f in
            f(&self.state)
            }, pushViewController: { [unowned self] vc in
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
            }, popViewController: { [unowned self] in
                self.formViewController.navigationController?.popViewController(animated: true)
        })
        let (sections, observer) = build(context)
        self.sections = sections
        self.observer = observer
        observer.update(state)
        formViewController = FormViewController(sections: sections, title: "Personal Hotspot Settings")
    }
    
    var state : State {
        didSet {
            observer.update(state)
            formViewController.reloadSectionFooters()
        }
    }
}

class Section {
    let cells: [FormCell]
    var footerTitle: String?
    init(cells: [FormCell], footerTitle: String?) {
        self.cells = cells
        self.footerTitle = footerTitle
    }
}

class FormCell: UITableViewCell {
    var shouldHighlight: Bool = false
    var didSelect:(()->Void)?
}

class FormViewController: UITableViewController {
    
    var sections: [Section] = []
    var firstResponder: UIResponder?
    
    init(sections: [Section], title: String, firstResponder: UIResponder? = nil) {
        self.sections = sections
        self.firstResponder = firstResponder
        super.init(style: .grouped)
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstResponder?.becomeFirstResponder()
    }
    
    func reloadSectionFooters() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        for index in sections.indices {
            let footerView = tableView.footerView(forSection: index)
            footerView?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footerView?.setNeedsLayout()
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
}
