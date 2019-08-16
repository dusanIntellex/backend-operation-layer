//
//  BRSendigExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/19/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import BackendServiceAdapter

class BRSendigExample : BackendRequest, UploadFileProtocol{
    
    var uploadFile: UploadFile?
    
    func route() -> String {
        return "endpoint"
    }
    
    func method() -> HttpMethod {
        return .post
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
        return .jsonBody
    }
}

