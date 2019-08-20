//
//  BRPostSampleRequest.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter


class BRPostSampleRequest : NSObject, BackendRequest{
    
    var model : ExampleModel!
    
    init(model: ExampleModel) {
        super.init()
        self.model = model
    }
    
    func executor() -> RequestExecutorType {
        return .urlSession
    }
    
    func baseUrl() -> String {
        return "https://jsonplaceholder.typicode.com"
    }
    
    func route() -> String{
        return "posts"
    }
    
    func method() -> HttpMethod{
        return .post
    }
    func headers() -> Dictionary<String, String>?{
        return nil
    }
    
    func params() -> [String: Any]?{
        return EncodingHelper.encode(model: model)
    }
    
    func parametersEncodingType() -> ParametersEncodingType? {
        return .jsonBody
    }
    
    func taskType() -> TaskType{
        return .rest
    }
}
