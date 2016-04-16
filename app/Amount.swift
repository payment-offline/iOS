//
//  Amount.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import Valet
import RxSwift

class Amount {

    private let valetManager = VALValet(identifier: "valet.payof", accessibility: .WhenPasscodeSetThisDeviceOnly)
    private let storeKeyAmount = "amount"
    
    static let sharedInstance = Amount()
    
    private var _amountVar: Double?
    
    private var _amount: Variable<Double?>
    
    class var observable: Observable<Double?> {
        return sharedInstance._amount.asObservable()
    }
    
    class var amount: Double {
        get {
            return sharedInstance._amount.value ?? 0
        }
        set {
            sharedInstance.valetManager?.setString("\(newValue)", forKey: sharedInstance.storeKeyAmount)
            sharedInstance._amount.value = newValue
        }
    }
    
    init() {
        _amount = Variable(nil)
        guard let amountString = valetManager?.stringForKey(storeKeyAmount) else {
            return
        }
        _amount.value = Double(amountString)
    }
}
