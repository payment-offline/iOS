//
//  PaymentAPI.swift
//  app
//
//  Created by Remi Robert on 16/04/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

enum PaymentAPI {
    case Status
    case Charge(amount: Double, channel: String)
}

extension PaymentAPI: NetworkRequest {

    func parameters() -> [String: AnyObject]? {
        switch self {
        case .Charge(let amount, let channel):
            return ["money": amount, "channel": channel]
        default:
            return nil
        }
    }
    
    func path() -> String {
        let basePath = "http://heckpsi.com:8080"
        
        switch self {
        case .Status:
            return "\(basePath)/status"
        case .Charge:
            return "\(basePath)/charge"
        }
    }
    
    func method() -> NetworkMethod {
        switch self {
        case .Status:
            return  .GET
        case .Charge:
            return .POST
        }
    }
}
