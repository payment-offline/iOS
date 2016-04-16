//
//  PayViewModel.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import Starscream

class ChargeViewModel {
    
    private var socket: WebSocket!
    var amount = Variable(Amount())
    
    private func createPayment(order: JSON?) -> Observable<PingppsPaymentResult> {
        return Observable.create({ observer in
            Pingpp.createPayment(order, appURLScheme: kAppURLScheme) { (result: String!, err: PingppError!) in
                if let err = err {
                    observer.onError(NSError(domain: err.getMsg(), code: 400, userInfo: nil))
                }
                else {
                    observer.onNext(PingppsPaymentResult.result(result))
                }
            }
            return NopDisposable.instance
        })
    }
    
    private func parseOrder(json: JSON?) -> String? {
        guard let json = json, let order = json["order_no"] as? String else {
            return nil
        }
        return order
    }
    
    func charge(amount: Double) -> Observable<PingppsPaymentResult> {
        let request = PaymentAPI.Charge(amount: 100, channel: "applepay_upacp")
        
        return Network.send(request: request).flatMap { (response: JSON?) -> Observable<PingppsPaymentResult> in
            if let order = self.parseOrder(response) {
                self.connectForOrder(order)
            }
            return self.createPayment(response)
            }.flatMap({ (result: PingppsPaymentResult) -> Observable<PingppsPaymentResult> in
                switch result {
                case .Success:
                    self.amount.value.amount = amount + (self.amount.value.amount ?? 0)
                default: break
                }
                return Observable.just(result)
            })
    }
}

extension ChargeViewModel: WebSocketDelegate {
    
    func connectForOrder(order: String) {
        guard let url = NSURL(string: "ws://heckpsi.com:8080/waiting/\(order)") else {
            return
        }
        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("socket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("socket disconnected with error : \(error)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("get message from socket : \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("get data from socket : \(data)")
    }
}
