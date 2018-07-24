//
//  BRRestSampleRequest.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class BRRestSampleRequest: NSObject , BackendRequest{
    
    func endpoint() -> String {
        return "https://jsonplaceholder.typicode.com/posts/1"
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
}
