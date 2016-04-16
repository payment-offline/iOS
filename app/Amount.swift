//
//  Amount.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import Valet

struct Amount {

    private let valetManager = VALValet(identifier: "valet.payof", accessibility: .WhenUnlocked)
    private let storeKeyAmount = "amount"
    
    var amount: Double? {
        didSet {
            guard let amount = amount else {
                return
            }
            valetManager?.setString("\(amount)", forKey: storeKeyAmount)
        }
    }
    
    init() {
        guard let amountString = valetManager?.stringForKey(storeKeyAmount) else {
            return
        }
        amount = Double(amountString)
    }
}
