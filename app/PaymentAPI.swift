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
}

extension PaymentAPI: NetworkRequest {

    func parameters() -> [String: AnyObject]? {
        return nil
    }
    
    func path() -> String {
        let basePath = "http://heckpsi.com:8080"
        
        switch self {
        case .Status:
            return "\(basePath)/status"
        }
    }
    
    func method() -> NetworkMethod {
        switch self {
        case .Status:
            return  .GET
        }
    }
}
