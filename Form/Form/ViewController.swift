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
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

struct Section {
    var cells: [FormCell]
    var footerTitle: String?
}

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> Void)?
}


class ViewController: UITableViewController {
    
    var sections: [Section] = []
    
    var state = Hotspot() {
        didSet {
            print(state)
            sections[0].footerTitle = state.enabledSectionTitle
            sections[1].cells[0].detailTextLabel?.text = state.password
            
            reloadSectionFooters()
        }
    }
    
    func reloadSectionFooters() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        for index in sections.indices {
            let footer = tableView.footerView(forSection: index)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footer?.setNeedsLayout()
            
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func buildSections() {
        let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
        toggleCell.textLabel?.text = "Personal Hotspot"
        toggleCell.contentView.addSubview(toggle)
        toggle.isOn = state.isEnabled
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        toggleCell.contentView.addConstraints([
            toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        
        let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
        passwordCell.textLabel?.text = "Password"
        passwordCell.detailTextLabel?.text = state.password
        passwordCell.accessoryType = .disclosureIndicator
        passwordCell.shouldHighlight = true
        
        let passwordVC = PasswordViewController(password: state.password) { [unowned self] in
            self.state.password = $0
        }
        
        passwordCell.didSelect = { [unowned self] in
            self.navigationController?.pushViewController(passwordVC, animated: true)
        }
        
        sections = [
            Section(cells: [
                toggleCell
                ], footerTitle: state.enabledSectionTitle),
            Section(cells: [
                passwordCell
                ], footerTitle: nil),
        ]
    }
    
    init() {
        super.init(style: .grouped)
        buildSections()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    var toggle = UISwitch()
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return sections[indexPath.section].cells[indexPath.row]
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
    
    @objc func toggleChanged(_ sender: Any) {
        state.isEnabled = toggle.isOn
    }
}

