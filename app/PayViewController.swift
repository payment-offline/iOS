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
import Starscream

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
    
    var socket: WebSocket!
    
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
    
    func parseOrder(json: JSON?) -> String? {
        guard let json = json, let order = json["order_no"] as? String else {
            return nil
        }
        return order
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = PaymentAPI.Charge(amount: 54.7, channel: "applepay_upacp")
        
        Network.send(request: request).flatMap { (response: JSON?) -> Observable<PingppsPaymentResult> in
            if let order = self.parseOrder(response) {
                self.connectForOrder(order)
            }
            return self.createPayment(response)
            }.subscribe { (event) in
                switch event {
                case .Next(let result) where result == .Success:
                    print("result : \(result)")
                case .Error(let error):
                    print("error : \(error)")
                default: break
                }
        }.addDisposableTo(rx_disposeBag)
    }
}

extension PayViewController: WebSocketDelegate {
    
    func connectForOrder(order: String) {
        guard let url = NSURL(string: "http://heckpsi.com:8080/waiting/\(order)") else {
            return
        }
        print("connecting on socket url : \(url)")
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
