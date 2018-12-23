//
//  PasswordViewController.swift
//  Form
//
//  Created by iSXQ on 2018/12/16.
//  Copyright © 2018 isxq. All rights reserved.
//

import UIKit

typealias Element<El, A> = (RenderingContext<A>) -> RenderedElement<El, A>
typealias Form<A> = Element<[Section], A>
typealias RenderedSection<A> = Element<Section, A>

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
            formViewController.reloadSections()
        }
    }
}

class Section: Equatable {
    
    let cells: [FormCell]
    var footerTitle: String?
    init(cells: [FormCell], footerTitle: String?) {
        self.cells = cells
        self.footerTitle = footerTitle
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs === rhs
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
    
    func reloadSections() {
        tableView.beginUpdates()
        for index in sections.indices {
            let footerView = tableView.footerView(forSection: index)
            footerView?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footerView?.setNeedsLayout()
        }
        tableView.endUpdates()
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

func uiswitich<State>(keyPath: WritableKeyPath<State, Bool>) -> Element<UIView, State> {
    return { context in
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
}


func textField<State>(keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
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
}

func controlCell<State>(title: String, control: @escaping Element<UIView, State>, leftAligned: Bool = false)-> Element<FormCell, State> {
    return { context in
        let renderedControl = control(context)
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.contentView.addSubview(renderedControl.element)
        cell.textLabel?.text = title
        cell.contentView.addConstraints([
            renderedControl.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        if leftAligned {
            cell.contentView.addConstraint( renderedControl.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20))
        }
        return RenderedElement(element: cell, strongRefrences: renderedControl.strongRefrences, update: renderedControl.update)
    }
}

func optionCell<Input: Equatable, State>(title: String, option: Input, keyPath: WritableKeyPath<State, Input>)->Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.shouldHighlight = true
        cell.didSelect = {
            context.change { $0[keyPath: keyPath] = option }
        }
        return RenderedElement.init(element: cell, strongRefrences: [], update: { state in
            cell.accessoryType = state[keyPath: keyPath] == option ? .checkmark : .none
        })
        
    }
}

func detailTextCell<State>(title: String, keyPath: KeyPath<State, String>, form: @escaping Element<[Section], State>) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.shouldHighlight = true
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        let renderedForm = form(context)
        let nested = FormViewController(sections:renderedForm.element, title: title)
        cell.didSelect = {
            context.pushViewController(nested)
        }
        
        return RenderedElement(element: cell, strongRefrences: [], update: { state in
            cell.detailTextLabel?.text = state[keyPath: keyPath]
            renderedForm.update(state)
            nested.reloadSections()
        })
    }
}

func section<State>(_ cells: [Element<FormCell, State>], footer keyPath: KeyPath<State, String?>? = nil) -> RenderedSection<State> {
    return { context in
        let renderedCells = cells.map{ $0(context) }
        let section = Section(cells: renderedCells.map{$0.element}, footerTitle: nil)
        return RenderedElement(
            element: section,
            strongRefrences: renderedCells.flatMap{$0.strongRefrences},
            update: { state in
                renderedCells.forEach{$0.update(state)}
                if let kp = keyPath {
                    section.footerTitle = state[keyPath: kp]
                }
        })
    }
}

func sections<State>(_ sections: [RenderedSection<State>]) -> Form<State> {
    return { context in
        let renderedSections = sections.map{$0(context)}
        return RenderedElement.init(
            element: renderedSections.map{$0.element},
            strongRefrences: renderedSections.flatMap{$0.strongRefrences},
            update: { state in
                renderedSections.forEach{$0.update(state)
                }
        })
    }
}
