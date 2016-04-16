//
//  Network.swift
//  YooplessIOS
//
//  Created by Remi Robert on 10/03/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

typealias JSON = [String: AnyObject]

public enum NetworkMethod: String {
    case GET, POST, PUT, DELETE
    
    func alamofireMethod() -> Alamofire.Method {
        switch self {
        case .GET: return Alamofire.Method.GET
        case .POST: return Alamofire.Method.POST
        case .PUT: return Alamofire.Method.PUT
        case .DELETE: return Alamofire.Method.DELETE
        }
    }
}

protocol NetworkRequest {
    func parameters() -> [String: AnyObject]?
    func path() -> String
    func method() -> NetworkMethod
    func headers() -> [String: String]?
}

extension NetworkRequest {
    func parameters() -> [String: AnyObject]? { return nil }
    func headers() -> [String: String]? { return nil }
}

class Network {
    
    private var tasks = Array<Request>()
    
    private class var sharedInstance: Network {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Network? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Network()
        }
        return Static.instance!
    }
    
    private static func handleJSONResponse(request: Request, observer: AnyObserver<JSON?>) {
        request.validate().responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) -> Void in
            switch response.result {
            case .Success(let value):
                observer.onNext(value as? [String: AnyObject])
                observer.onCompleted()
            case .Failure(let err):
                observer.onError(err)
            }
        })
    }
    
    static func send(request request: NetworkRequest) -> Observable<JSON?> {
        let method = request.method().alamofireMethod()
        let path = request.path()
        let parameters = request.parameters()
        let headers = request.headers()
        
        let request = Alamofire.request(method, path, parameters: parameters, encoding: .JSON, headers: headers)
        self.sharedInstance.tasks.append(request)

        return Observable.create { observer in
            self.handleJSONResponse(request, observer: observer)

            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
    static func send<A>(request request: NetworkRequest, parse: JSON -> A?) -> Observable<A?> {
        return self.send(request: request).flatMap { (response: JSON?) -> Observable<A?> in
            guard let json = response else {
                return Observable.just(nil)
            }
            return Observable.just(parse(json))
        }
    }
}
