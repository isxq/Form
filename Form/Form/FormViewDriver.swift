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

let passwordForm: Form<Hotspot> =
    sections([
        section([
            controlCell(title: "Password", control: textField(keyPath: \.password))
        ])
    ])

let hotspotForm: Form<Hotspot> =
    sections([
        section([
            controlCell(title: "Personal Hotspot", control: uiswitich(keyPath: \.isEnabled))
            ], footer: \.enableSectionTitle),
        section([
            detailTextCell(title: "Password", keyPath: \.password, form: passwordForm)
            ])
        ])
