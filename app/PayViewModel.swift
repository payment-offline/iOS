//
//  PayViewModel.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift

class PayViewModel {
    
    private var voiceSendRecognizer = VoiceSendRecognizer()
    private var voiceListenRecognizer = VoiceListenRecognizer()
    
    private func sendString(string: String) -> Observable<Void> {
        self.voiceSendRecognizer = VoiceSendRecognizer()
        return Observable.create({ observer in
            self.voiceSendRecognizer.startPlay(string, completion: {
                return observer.onNext()
            })
            return AnonymousDisposable {
                self.voiceSendRecognizer.stopPlay()
            }
        })
    }
    
    private func receiveString() -> Observable<String?> {
        return Observable.create({ observer in
            self.voiceListenRecognizer.startRecord({ string in
                observer.onNext(string)
            })
            return AnonymousDisposable {
                self.voiceListenRecognizer.stopRecord()
            }
        })
    }
    
    func askPayment() -> Observable<Double?> {
        return sendString("WTP").flatMap { (_: ()) -> Observable<String?> in
            return self.receiveString()
            }.map { (string: String?) -> Double? in
                guard let string = string else {
                    return nil
                }
                return Double(string)
        }
    }
    
    func confirmPayment() -> Observable<Void> {
        return sendString("OKC")
    }
    
    func cancelPayment() {
        self.voiceListenRecognizer.stopRecord()
        self.voiceSendRecognizer.stopPlay()
    }
}