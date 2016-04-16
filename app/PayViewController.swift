//
//  PayViewController.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class PayViewController: UIViewController {
    
    let voiceRecognizer = VoiceSendRecognizer()
    
    override func viewDidAppear(animated: Bool) {
        self.voiceRecognizer.startPlay("salut")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
