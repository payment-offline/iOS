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

class PayViewController: UIViewController {
    
    let viewModel = PayViewModel()
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func cancelPayment(sender: AnyObject) {
        self.viewModel.cancelPayment()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.payButton.layer.cornerRadius = self.payButton.frame.size.width / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.rx_tap.subscribeNext {
            self.payButton.hidden = true
            self.activityIndicator.startAnimating()
            
            self.viewModel.askPayment().subscribeNext({ amount in
            
                print("amount : \(amount)")
                
            }).addDisposableTo(self.rx_disposeBag)
            
        }.addDisposableTo(rx_disposeBag)
    }
}
