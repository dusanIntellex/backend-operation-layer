//
//  BRSendigExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/19/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation


struct BRSendigExample : BackendRequest, SendingDataProtocol, UploadFileProtocol{
    
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
    
    var sendingModel: Encodable
    var uploadFile: FileLoad
    
}
