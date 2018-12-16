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

class ViewController: UITableViewController {
    
    var state = Hotspot() {
        didSet {
            print(state)
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            let footer = tableView.footerView(forSection: 0)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: 0)
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 1))
            cell?.detailTextLabel?.text = state.password
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    let toggle = UISwitch()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        if indexPath.section == 0 {
            cell.contentView.addSubview(toggle)
            cell.textLabel?.text = "Personal Hotspot"
            toggle.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addConstraints([
                toggle.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                toggle.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
                ])
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            toggle.isOn = state.isEnabled
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "Password"
            cell.detailTextLabel?.text = state.password
            cell.accessoryType = .disclosureIndicator
        } else {
            fatalError()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return state.isEnabled ? "Personal Hotspot Enable" : nil
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let passwordVC = PasswordViewController(password: state.password){ [unowned self] in
                self.state.password = $0
            }
            navigationController?.pushViewController(passwordVC, animated: true)
            
        }
    }
    
    @objc func toggleChanged(_ sender: Any) {
        state.isEnabled = toggle.isOn
    }
}

