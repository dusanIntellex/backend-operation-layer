//
//  BRPostSampleRequest.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter


class BRPostSampleRequest : NSObject, BackendRequest, SendingProtocols{

    func getEncodedData() -> [String : Any]? {
        return self.encode()
    }
    func setSendingData(data: Encodable) {
        if let data = data as? ExampleModelObject{
            self.sendingModel = data
        }
    }
    typealias GenericEncodableType = ExampleModelObject
    var sendingModel: ExampleModelObject?
    
    func endpoint() -> String {
        return "https://jsonplaceholder.typicode.com/posts"
    }
    
    func method() -> HttpMethod {
        return .get
    }
    
    func headers() -> Dictionary<String, String>? {
        return nil
    }
    
    func requestType() -> RequestType? {
        return .rest
    }
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func encodingType() -> ParametersEncodingType? {
        return .jsonBody
    }
}
/*
class BRPostSampleRequest: NSObject, BackendRequest, SendingProtocols {
    
    func getEncodedData() -> [String : Any]? {
        return self.encode()
    }
    
    func setSendingData(data: Encodable) {
        if let data = data as? ExampleModelObject{
            self.sendingModel = data
        }
    }
    
    typealias GenericEncodableType = ExampleModelObject
    var sendingModel: ExampleModelObject?
    
    func endpoint() -> String {
        return "https://jsonplaceholder.typicode.com/posts"
    }
    
    func method() -> HttpMethod {
        return .post
    }
    
    func headers() -> Dictionary<String, String>? {
        return nil
    }
    
    func requestType() -> RequestType? {
        return .rest
    }
    
    func encodingType() -> ParametersEncodingType? {
        return .jsonBody
    }
}
*/
