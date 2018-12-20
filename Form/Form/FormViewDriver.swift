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


func hotspotForm(context: RenderingContext<Hotspot>) -> ([Section], Observer<Hotspot>) {
    var strongRefrences: [Any] = []
    var updates: [(Hotspot) -> Void] = []
    
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    let toggle = UISwitch()
    toggle.translatesAutoresizingMaskIntoConstraints = false
    
    let toggleTarget = TargetAction {
        context.change{$0.isEnabled = toggle.isOn}
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
    
    //    let passwordDriver = FormDriver(initial: context.state, build: buildPasswordForm)
    let (sections, observer) = buildPasswordForm(context: context)
    let passwordForm = FormViewController(sections: sections, title: "Personal Hotspot Driver")
    
    let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
    passwordCell.shouldHighlight = true
    passwordCell.textLabel?.text = "Password"
    passwordCell.accessoryType = .disclosureIndicator
    passwordCell.didSelect = {
        context.pushViewController(passwordForm)
    }
    
    updates.append{ state in
        passwordCell.detailTextLabel?.text = state.password
    }
    
    let toggleSection = Section(cells: [
        toggleCell
        ], footerTitle: context.state.enableSectionTitle)
    
    updates.append{ state in
        toggleSection.footerTitle = state.enableSectionTitle
    }
    
    return ([
        toggleSection,
        Section(cells: [
            passwordCell
            ], footerTitle: nil)
        ], Observer(strongRefrences: (strongRefrences + observer.strongRefrences), update: { state in
            observer.update(state)
            updates.forEach{$0(state)}
        }))
}

func buildPasswordForm(context: RenderingContext<Hotspot>) -> ([Section], Observer<Hotspot>){
    let textfield = UITextField()
    let update: (Hotspot)->Void = { state in
        textfield.text = state.password
    }
    
    let ta1 = TargetAction {
        context.change{ $0.password = textfield.text ?? "" }
    }
    
    let ta2 = TargetAction {
        context.change{ $0.password = textfield.text ?? "" }
        context.popViewController()
    }
    
    textfield.addTarget(ta1, action: #selector(ta1.action(_:)), for: .editingDidEnd)
    textfield.addTarget(ta2, action: #selector(ta2.action(_:)), for: .editingDidEndOnExit)
    
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = "Password"
    cell.contentView.addSubview(textfield)
    textfield.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addConstraints([
        textfield.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        textfield.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        textfield.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
        ])
    
    return ([Section(cells: [cell], footerTitle: nil)],
            Observer(strongRefrences:[ta1, ta2], update: update))
}

