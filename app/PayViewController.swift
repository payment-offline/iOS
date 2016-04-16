//
//  PayViewController.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift

class PayViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = PaymentAPI.Status
        
        Network.send(request: request).subscribe { (event) in
            switch event {
            case .Next(let response):
                print("response : \(response)")
            case .Error(let error):
                print("error : \(error)")
            default: break
            }
        }.addDisposableTo(self.disposeBag)
    }
}
