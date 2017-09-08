//
//  BasicNetwork.swift
//  GearNetwork
//
//  Created by 王小涛 on 2017/9/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import GearNetwork
import RxSwift
import Alamofire

class NetworkService {
    
    let urlRequest: URLRequestConvertible
    
    init(urlRequest: URLRequestConvertible) {
        self.urlRequest = urlRequest
    }
    
    fileprivate func responseData()
        -> Observable<Any> {
            
            return SessionManager.default.rx.json(urlRequest: urlRequest).map {
                
                guard let json = $0 as? [String: Any] else {
                    throw NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "返回的数据不是json格式"])
                }
                
                guard let errorCode = json["error_code"] as? Int, errorCode == 0 else {
                    let errorMessage = json["error_message"] as? String
                    throw NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "返回的数据格式没有按照约定返回"])
                }
                
                guard let data = json["data"] else {
                    throw NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "返回数据中data为空"])
                }
                
                return data
            }
    }
}

class SingleDataService: NetworkService {
    func response<T: Modelable>() -> Observable<T> {
        return responseData().map {
            return try T(value: $0)
        }
    }
}

class ArrayDataService: NetworkService {
    func response<T: Modelable>() -> Observable<[T]> {
        return responseData().map {
            return try T.makeModels(fromValue: $0)
        }
    }
}
