//
//  ViewController.swift
//  Form
//
//  Created by iSXQ on 2018/12/16.
//  Copyright © 2018 isxq. All rights reserved.
//

import UIKit

import UIKit

enum ShowPreview {
    case alway
    case never
    case whenUnlocked
    
    static let all: [ShowPreview] = [.alway, .never, .whenUnlocked]
    
    var text: String {
        switch self {
        case .alway: return "Alway"
        case .never: return "Never"
        case .whenUnlocked: return "When Unlocked"
        }
    }
}

struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "Hello"
    var networkName: String = "My Network"
    var showPreview: ShowPreview = .alway
}

extension Hotspot {
    var enableSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

struct Settings {
    var hotspot = Hotspot()
    var hotspotEnable: String {
        return hotspot.isEnabled ? "On" : "Off"
    }
    
}

let settingsForm: Form<Settings> =
    sections([
        section([
            detailTextCell(title: "Personal Hotspot", keyPath: \.hotspotEnable, form: bind(form: hotspotForm, to: \.hotspot))
            ])
        ])

let showPreviewForm: Form<Hotspot> =
    sections([
        section(
            ShowPreview.all.map{ option in
                optionCell(title: option.text, option: option, keyPath: \.showPreview)
            }
        )
        ])

let hotspotForm: Form<Hotspot> =
    sections([
        section([
            controlCell(title: "Personal Hotspot", control: uiswitich(keyPath: \.isEnabled))
            ], footer: \.enableSectionTitle),
        section([
            detailTextCell(title: "Notification", keyPath: \.showPreview.text, form: showPreviewForm)
            ], isVisble: \.isEnabled),
        section([
            nestedTextField(title: "Password", keyPath: \.password),
            nestedTextField(title: "NetworkName", keyPath: \.networkName)
            ], isVisble: \.isEnabled)
        ])



