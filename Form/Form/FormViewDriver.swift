//
//  ViewController.swift
//  Form
//
//  Created by iSXQ on 2018/12/16.
//  Copyright © 2018 isxq. All rights reserved.
//

import UIKit

struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "Hello"
}

extension Hotspot {
    var enableSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

final class TargetAction {
    let excute: ()->Void
    init(_ excute: @escaping ()->Void) {
        self.excute = excute
    }
    
    @objc func action(_ sender: Any) {
        excute()
    }
}

struct Observer {
    var strongRefrences: [Any]
    var update: (Hotspot) -> Void
    
}

func hotspotForm(state: Hotspot, change: @escaping ((inout Hotspot)->Void)-> Void, pushViewController: @escaping (UIViewController) -> Void ) -> ([Section], Observer) {
    var strongRefrences: [Any] = []
    var updates: [(Hotspot) -> Void] = []
    
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    let toggle = UISwitch()
    toggle.isOn = state.isEnabled
    toggle.translatesAutoresizingMaskIntoConstraints = false
    let toggleTarget = TargetAction {
        change{$0.isEnabled = toggle.isOn}
    }
    strongRefrences.append(toggleTarget)
    updates.append{ state in
        toggle.isOn = state.isEnabled
    }
    toggle.addTarget(toggleTarget, action: #selector(toggleTarget.action(_:)), for: .valueChanged)
    toggleCell.contentView.addSubview(toggle)
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addConstraints([
        toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
        toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    
    let passwordDriver = PasswordDriver(password: state.password) { newPassword in
        change{$0.password = newPassword}
    }
    
    
    
    let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
    passwordCell.shouldHighlight = true
    passwordCell.textLabel?.text = "Password"
    passwordCell.detailTextLabel?.text = state.password
    passwordCell.accessoryType = .disclosureIndicator
    passwordCell.didSelect = {
        pushViewController(passwordDriver.formViewController)
    }
    
    updates.append{ state in
        passwordCell.detailTextLabel?.text = state.password
    }
    
    let toggleSection = Section(cells: [
        toggleCell
        ], footerTitle: state.enableSectionTitle)
    
    updates.append{ state in
        toggleSection.footerTitle = state.enableSectionTitle
    }
    
    return ([
        toggleSection,
        Section(cells: [
            passwordCell
            ], footerTitle: nil)
        ], Observer(strongRefrences: strongRefrences, update: { state in
            updates.forEach{$0(state)}
        }))
}

class FormDriver {
    var formViewController: FormViewController!
    var sections: [Section] = []
    var observer: Observer!
    
    init(initial state: Hotspot, build: (Hotspot, @escaping ((inout Hotspot)->Void)->Void, _ pushViewController: @escaping (UIViewController) -> Void) -> ([Section], Observer)) {
        self.state = state
        let (sections, observer) = build(state, { [unowned self] f in
            f(&self.state)
            }, { [unowned self] vc in
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
        })
        self.sections = sections
        self.observer = observer
        formViewController = FormViewController(sections: sections, title: "Personal Hotspot Settings")
    }
    
    var state = Hotspot() {
        didSet {
            observer.update(state)
            formViewController.reloadSectionFooters()
        }
    }
}

class PasswordDriver {
    
    let textfield = UITextField()
    var onChange: (String)-> Void
    var formViewController: FormViewController!
    var sections: [Section] = []
    
    init(password: String, onChange: @escaping (String)-> Void) {
        self.onChange = onChange
        buildSections()
        self.formViewController = FormViewController(sections: sections, title: "Hotspot Password", firstResponder: textfield)
        textfield.text = password
    }
    
    func buildSections() {
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Password"
        cell.contentView.addSubview(textfield)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.addTarget(self, action: #selector(editingEnded(_:)), for: .editingDidEnd)
        textfield.addTarget(self, action: #selector(editingDidEnter(_:)), for: .editingDidEndOnExit)
        cell.contentView.addConstraints([
            textfield.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            textfield.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            textfield.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
            ])
        
        sections = [
            Section(cells: [cell], footerTitle: nil)
        ]
    }
    
    
    @objc func editingEnded(_ sender: Any) {
        onChange(textfield.text ?? "")
    }
    
    @objc func editingDidEnter(_ sender: Any) {
        onChange(textfield.text ?? "")
        formViewController.navigationController?.popViewController(animated: true)
    }
    
}
