//
//  BRSendigExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/19/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import BackendServiceAdapter

class BRSendigExample : BackendRequest, PostDataProtocol, UploadFileProtocol{
    
    var uploadFile: FileLoad?
    var sendingModel: ExampleModel?
    typealias GenericEncodableType = ExampleModel
    
    func endpoint() -> String {
        return "endpoint"
    }
    
    func specificUrl() -> String?{
        return nil
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
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func encodingType() -> ParametersEncodingType? {
        return .jsonBody
    }
}

