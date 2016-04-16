//
//  PayViewController.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

let kAppURLScheme = "demoappswift"

enum PingppsPaymentResult {
    case Success
    case Canceled
    case Failed
    
    static func result(result: String) -> PingppsPaymentResult {
        switch result {
        case "success":
            return .Success
        case "cancel":
            return .Canceled
        default: return .Failed
        }
    }
}

class PayViewController: UIViewController {

    let viewModel = PayViewModel()
    
    @IBOutlet weak var chargeButton: UIButton!
    @IBOutlet weak var labelBalance: UILabel!
    
    func displayPromptAmount() -> Observable<Double?> {
        let alertController = UIAlertController(title: "Enter your amount", message: "Will recharge your local wallet", preferredStyle: .Alert)

        return Observable.create({ observer in
            let loginAction = UIAlertAction(title: "Charge", style: .Default) { (_) in
                let loginTextField = alertController.textFields![0] as UITextField
                
                if let textAmount = loginTextField.text {
                    let amount = Double(textAmount)
                    observer.onNext(amount)
                }
                else {
                    observer.onNext(nil)
                }
            }
            loginAction.enabled = false
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive) { (_) in
                observer.onNext(nil)
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Login"
                textField.keyboardType = .NumberPad
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                    loginAction.enabled = textField.text != ""
                }
            }
            
            alertController.addAction(loginAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return NopDisposable.instance
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.amount.asObservable().subscribeNext { amount in
            dispatch_async(dispatch_get_main_queue(), {
                self.labelBalance.text = "\(amount.amount ?? 0)"
            })
        }.addDisposableTo(rx_disposeBag)
        
        self.chargeButton.rx_tap.retry().flatMap { (_: ()) -> Observable<Double?> in
            return self.displayPromptAmount()
            }.flatMap { (amount: Double?) -> Observable<PingppsPaymentResult> in
                guard let amount = amount else {
                    return Observable.just(.Canceled)
                }
                return self.viewModel.charge(amount)
        }.retry().subscribe { (event) in
            switch event {
            case .Next(let status):
                print("event status : \(status)")
            case .Error(let error):
                print("error : \(error)")
            default: break
            }
        }.addDisposableTo(rx_disposeBag)
    }
}

