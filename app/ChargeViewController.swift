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

class ChargeViewController: UIViewController {

    let viewModel = ChargeViewModel()
    
    @IBOutlet weak var chargeButton: UIButton!
    @IBOutlet weak var labelBalance: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Amount.observable.subscribeNext { amount in
            dispatch_async(dispatch_get_main_queue(), {
                self.labelBalance.text = "\(amount ?? 0)"
            })
        }.addDisposableTo(rx_disposeBag)
        
        self.chargeButton.rx_tap.retry().flatMap { (_: ()) -> Observable<Double?> in
            return PromptAlert.show(self, title: "Enter the charge amount", message: "will charge you current balance")
            }.flatMap { (amount: Double?) -> Observable<PingppsPaymentResult> in
                guard let amount = amount else {
                    return Observable.just(.Canceled)
                }
                return self.viewModel.charge(amount)
        }.subscribe { (event) in
            switch event {
            case .Next(let status):
                self.displayMessageAlert("Status charge : \(status)")
            case .Error(let error):
                self.displayMessageAlert("Error charge : \(error)")
            default: break
            }
        }.addDisposableTo(rx_disposeBag)
    }
}

extension ChargeViewController {
 
    func displayMessageAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) in }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

