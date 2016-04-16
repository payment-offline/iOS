//
//  PayViewController.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class PayViewController: UIViewController {
    
    let viewModel = PayViewModel()
    let voiceSendRecognizer = VoiceSendRecognizer()
    let voiceListenRecognizer = VoiceListenRecognizer()
    
    @IBAction func cancelPayment(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.voiceListenRecognizer.startRecord { text in
            guard let text = text else {
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
