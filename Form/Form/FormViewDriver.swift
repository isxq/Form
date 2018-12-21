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

func uiswitich<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, Bool>) -> RenderElement<UIView, State> {
    
    let toggle = UISwitch()
    toggle.translatesAutoresizingMaskIntoConstraints = false
    let toggleTarget = TargetAction {
        context.change{$0[keyPath: keyPath] = toggle.isOn}
    }
    toggle.addTarget(toggleTarget, action: #selector(toggleTarget.action(_:)), for: .valueChanged)
    return RenderElement(element: toggle, strongRefrences: [toggleTarget], update: { state in
        toggle.isOn = state[keyPath: keyPath]
    })
}


func textField<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, String>) -> RenderElement<UIView, State> {
    
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
    return RenderElement(element: textfield, strongRefrences:[didEnd, didExit], update: { state in
        textfield.text = state[keyPath: keyPath]
    })
}

func hotspotForm(context: RenderingContext<Hotspot>) -> RenderElement<[Section], Hotspot> {
    var strongRefrences: [Any] = []
    var updates: [(Hotspot) -> Void] = []
    
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    let renderedToggle = uiswitich(context: context, keyPath: \Hotspot.isEnabled)
    strongRefrences.append(contentsOf: renderedToggle.strongRefrences)
    updates.append(renderedToggle.update)
    let toggle = renderedToggle.element
    toggleCell.contentView.addSubview(toggle)
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addConstraints([
        toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
        toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    
    let renderedPasswordForm = buildPasswordForm(context: context)
    let passwordForm = FormViewController(sections: renderedPasswordForm.element, title: "Personal Hotspot Driver")
    
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
    
    return RenderElement(element: [
        toggleSection,
        Section(cells: [
            passwordCell
            ], footerTitle: nil)
        ], strongRefrences: (strongRefrences + renderedPasswordForm.strongRefrences), update: { state in
            renderedPasswordForm.update(state)
            updates.forEach{$0(state)}
    })
}

func buildPasswordForm(context: RenderingContext<Hotspot>) -> RenderElement<[Section], Hotspot>{
    
    
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = "Password"
    let renderedPasswordField = textField(context: context, keyPath: \.password)
    let textfield = renderedPasswordField.element
    cell.contentView.addSubview(textfield)
    cell.contentView.addConstraints([
        textfield.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        textfield.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        textfield.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
        ])
    
    return RenderElement(element: [Section(cells: [cell], footerTitle: nil)], strongRefrences: renderedPasswordField.strongRefrences, update: renderedPasswordField.update)
}

