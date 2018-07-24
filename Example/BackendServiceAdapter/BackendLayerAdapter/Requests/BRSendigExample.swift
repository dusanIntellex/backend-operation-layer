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
    
    var sendingModel: ExampleModel?
    typealias GenericEncodableType = ExampleModel

    var uploadFile: FileLoad?
    
    func endpoint() -> String {
        return "endpoint"
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
