//
//  PayViewController.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift
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
    
    func createPayment(order: JSON?) -> Observable<PingppsPaymentResult> {
        return Observable.create({ observer in
            Pingpp.createPayment(order, appURLScheme: kAppURLScheme) { (result: String!, err: PingppError!) in
                if let err = err {
                    observer.onError(NSError(domain: err.getMsg(), code: 400, userInfo: nil))
                }
                else {
                    observer.onNext(PingppsPaymentResult.result(result))
                    observer.onCompleted()
                }
            }
            return NopDisposable.instance
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = PaymentAPI.Charge(amount: 54.7, channel: "applepay_upacp")
        
        Network.send(request: request).flatMap { (response: JSON?) -> Observable<PingppsPaymentResult> in
            return self.createPayment(response)
            }.subscribe { (event) in
                switch event {
                case .Next(let result):
                    print("result : \(result)")
                case .Error(let error):
                    print("error : \(error)")
                default: break
                }
            }.addDisposableTo(rx_disposeBag)
    }
}
