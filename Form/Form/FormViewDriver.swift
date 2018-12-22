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

func section<State>(_ renderedCells: [RenderedElement<FormCell, State>], footer keyPath: KeyPath<State, String?>? = nil) -> RenderedElement<Section, State> {
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

func sections<State>(_ renderedSections: [RenderedElement<Section, State>]) -> RenderedElement<[Section], State> {
    return RenderedElement.init(
        element: renderedSections.map{$0.element},
        strongRefrences: renderedSections.flatMap{$0.strongRefrences},
        update: { state in
            renderedSections.forEach{$0.update(state)}
    })
}

func hotspotForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    let renderedToggle = uiswitich(context: context, keyPath: \Hotspot.isEnabled)
    let renderedToggleCell = controlCell(title: "Personal Hotspot", control: renderedToggle)
    
    let renderedPasswordForm = buildPasswordForm(context: context)
    let nested = FormViewController(sections: renderedPasswordForm.element, title: "Personal Hotspot Password")
    
    let passwordCell = detailTextCell(title: "Password", keyPath: \Hotspot.password) {
        context.pushViewController(nested)
    }
    
    let toggleSection = section([renderedToggleCell])
    //    updates.append { state in
    //        toggleSection.footerTitle = state.enabledSectionTitle
    //    }
    
    let passwordSection = section([passwordCell])
    
    // TODO: renderedPasswordForm.strongReferences,
    // renderedPasswordForm.update(state)
    
    return sections([toggleSection, passwordSection])
    
    
    
}

func buildPasswordForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot>{
    
    let renderedPasswordField = textField(context: context, keyPath: \.password)
    let passwordCell = controlCell(title: "Password", control: renderedPasswordField, leftAligned: true)
    return sections([section([passwordCell])])
}

