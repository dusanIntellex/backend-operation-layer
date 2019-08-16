//
//  BRRestSampleRequest.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter


class BRRestSampleRequest: NSObject , BackendRequest{
    
    func route() -> String {
        return "test"
    }
    
    func method() -> HttpMethod {
        return .get
    }
    
    func headers() -> Dictionary<String, String>? {
        return nil
    }
    
    func taskType() -> TaskType {
        return .rest
    }
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func parametersEncodingType() -> ParametersEncodingType? {
        return nil
    }
}
