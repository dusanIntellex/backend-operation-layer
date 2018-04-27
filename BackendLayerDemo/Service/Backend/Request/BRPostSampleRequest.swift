//
//  BRPostSampleRequest.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class BRPostSampleRequest: NSObject, BackendRequest, SendingDataProtocol {
    
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
        return .urlEncode
    }
    
    var sendingModel: BaseModel?
    

    
}
