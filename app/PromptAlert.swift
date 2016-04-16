//
//  PromptAlert.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift

class PromptAlert {

    class func show(parentController: UIViewController, title: String, message: String? = nil) -> Observable<Double?> {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        return Observable.create({ observer in
            let chargeAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
                let loginTextField = alertController.textFields![0] as UITextField
                
                if let textAmount = loginTextField.text {
                    let amount = Double(textAmount)
                    observer.onNext(amount)
                }
                else {
                    observer.onNext(nil)
                }
            }
            chargeAction.enabled = false
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (_) in
                observer.onNext(nil)
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Login"
                textField.keyboardType = .NumberPad
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                    chargeAction.enabled = textField.text != ""
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(chargeAction)
            
            parentController.presentViewController(alertController, animated: true, completion: nil)
            return NopDisposable.instance
        })
    }
}
