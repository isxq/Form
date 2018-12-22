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

struct RenderedElement<Element, State> {
    var element: Element
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
    var render: RenderedElement<[Section], State>!
    
    init(initial state: State, build: (RenderingContext<State>) -> RenderedElement<[Section], State>) {
        self.state = state
        let context = RenderingContext(state: state, change: { [unowned self] f in
            f(&self.state)
            }, pushViewController: { [unowned self] vc in
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
            }, popViewController: { [unowned self] in
                self.formViewController.navigationController?.popViewController(animated: true)
        })
        self.render = build(context)
        render.update(state)
        formViewController = FormViewController(sections: render.element, title: "Personal Hotspot Settings")
    }
    
    var state : State {
        didSet {
            render.update(state)
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

func uiswitich<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, Bool>) -> RenderedElement<UIView, State> {
    
    let toggle = UISwitch()
    toggle.translatesAutoresizingMaskIntoConstraints = false
    let toggleTarget = TargetAction {
        context.change{$0[keyPath: keyPath] = toggle.isOn}
    }
    toggle.addTarget(toggleTarget, action: #selector(toggleTarget.action(_:)), for: .valueChanged)
    return RenderedElement(element: toggle, strongRefrences: [toggleTarget], update: { state in
        toggle.isOn = state[keyPath: keyPath]
    })
}


func textField<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, String>) -> RenderedElement<UIView, State> {
    
    let textfield = UITextField()
    textfield.translatesAutoresizingMaskIntoConstraints = false
    
    let didEnd = TargetAction {
        context.change{ $0[keyPath: keyPath] = textfield.text ?? "" }
    }
    
    let didExit = TargetAction {
        context.change{ $0[keyPath: keyPath] = textfield.text ?? "" }
        context.popViewController()
    }
    
    textfield.addTarget(didEnd, action: #selector(didEnd.action(_:)), for: .editingDidEnd)
    textfield.addTarget(didExit, action: #selector(didExit.action(_:)), for: .editingDidEndOnExit)
    return RenderedElement(element: textfield, strongRefrences:[didEnd, didExit], update: { state in
        textfield.text = state[keyPath: keyPath]
    })
}

func controlCell<State>(title: String, control: RenderedElement<UIView, State>, leftAligned: Bool = false)-> RenderedElement<FormCell, State> {
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.contentView.addSubview(control.element)
    cell.textLabel?.text = title
    cell.contentView.addConstraints([
        control.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        control.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    if leftAligned {
        cell.contentView.addConstraint( control.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20))
    }
    return RenderedElement(element: cell, strongRefrences: control.strongRefrences, update: control.update)
}

func detailTextCell<State>(title: String, keyPath: KeyPath<State, String>, didSelect: @escaping () -> ()) -> RenderedElement<FormCell, State> {
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.didSelect = didSelect
    cell.textLabel?.text = title
    cell.accessoryType = .disclosureIndicator
    cell.shouldHighlight = true
    return RenderedElement(element: cell, strongRefrences: [], update: { state in
        cell.detailTextLabel?.text = state[keyPath: keyPath]
    })
}
