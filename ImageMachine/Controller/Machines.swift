//
//  Machine.swift
//  ImageMachine
//
//  Created by Fereizqo Sulaiman on 26/04/20.
//  Copyright © 2020 Fereizqo Sulaiman. All rights reserved.
//

import Foundation

struct Machines {
    let id: String
    let name: String
    let type: String
    let qrCode: Int
    let maintenanceDate: Date
    
    init(id: String, name: String, type: String, qrCode: Int, maintenanceDate: Date) {
        self.id = id
        self.name = name
        self.type = type
        self.qrCode = qrCode
        self.maintenanceDate = maintenanceDate
    }
}
