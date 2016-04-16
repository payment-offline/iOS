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
        self.viewModel.stopPayment()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.payButton.layer.cornerRadius = self.payButton.frame.size.width / 2
    }
    
    func askPaymentConfirmation(amount: Double) {
        let alertController = UIAlertController(title: "Do you want to pay", message: "for an amount of: \(amount)", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Destructive, handler: { (_) in
            self.viewModel.cancelPayment().subscribeNext({
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }).addDisposableTo(self.rx_disposeBag)
        }))
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) in
            self.viewModel.confirmPayment().subscribeNext({
                dispatch_async(dispatch_get_main_queue(), {
                    Amount.amount = Amount.amount - amount
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }).addDisposableTo(self.rx_disposeBag)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.rx_tap.subscribeNext {
            self.payButton.hidden = true
            self.activityIndicator.startAnimating()
            
            self.viewModel.askPayment().subscribeNext({ amount in
                guard let amount = amount else {
                    return
                }
                if (Amount.amount < amount) {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Not enough money", message: nil, preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) in }))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { 
                    self.askPaymentConfirmation(amount)
                })
            }).addDisposableTo(self.rx_disposeBag)
            
        }.addDisposableTo(rx_disposeBag)
    }
}
