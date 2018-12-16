//
//  PasswordViewController.swift
//  Form
//
//  Created by iSXQ on 2018/12/16.
//  Copyright © 2018 isxq. All rights reserved.
//

import UIKit

class PasswordViewController: UITableViewController {
    
    let textfield = UITextField()
    var onChange: (String)-> Void
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textfield.becomeFirstResponder()
    }
    
    init(password: String, onChange: @escaping (String)-> Void) {
        self.onChange = onChange
        super.init(style: .grouped)
        textfield.text = password
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hotspot Password"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
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
        return cell
    }
    
    @objc func editingEnded(_ sender: Any) {
        onChange(textfield.text ?? "")
    }
    
    @objc func editingDidEnter(_ sender: Any) {
        onChange(textfield.text ?? "")
    }
    
}
