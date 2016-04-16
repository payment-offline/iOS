//
//  PayViewController.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class PayViewController: UIViewController {
    
    let voiceSendRecognizer = VoiceSendRecognizer()
    let voiceListenRecognizer = VoiceListenRecognizer()
    
    override func viewDidAppear(animated: Bool) {
        self.voiceListenRecognizer.startRecord()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
