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

class HotspotDriver {
    var formViewController: FormViewController!
    var sections: [Section] = []
    let toggle = UISwitch()
    
    init() {
        buildSections()
        formViewController = FormViewController(sections: sections, title: "Personal Hotspot Settings")
    }
    
    var state = Hotspot() {
        didSet {
            print(state)
            sections[0].footerTitle = state.enableSectionTitle
            sections[1].cells[0].detailTextLabel?.text = state.password
            formViewController.reloadSectionFooters()
        }
    }
    
    func buildSections() {
        let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
        toggleCell.contentView.addSubview(toggle)
        toggleCell.textLabel?.text = "Personal Hotspot"
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggleCell.contentView.addConstraints([
            toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        toggle.isOn = state.isEnabled
        
        let passwordDriver = PasswordDriver(password: state.password) { [unowned self] in
            self.state.password = $0
        }
        
        let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
        passwordCell.shouldHighlight = true
        passwordCell.textLabel?.text = "Password"
        passwordCell.detailTextLabel?.text = state.password
        passwordCell.accessoryType = .disclosureIndicator
        passwordCell.didSelect = { [unowned self] in
            self.formViewController.navigationController?.pushViewController(passwordDriver.formViewController, animated: true)
        }
        
        sections = [
            Section(cells: [
                toggleCell
                ], footerTitle: state.enableSectionTitle),
            Section(cells: [
                passwordCell
                ], footerTitle: nil)
        ]
    }
    
    @objc func toggleChanged(_ sender: Any) {
        state.isEnabled = toggle.isOn
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
