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
    func baseUrl() -> String {
        return "https://jsonplaceholder.typicode.com"
    }
    
    func route() -> String{
        return "posts"
    }
    
    func method() -> HttpMethod{
        return .get
    }
    func headers() -> Dictionary<String, String>?{
        return nil
    }
    
    func params() -> [String: Any]?{
        return nil
    }
    
    /// Type which define how will parameters be encoded
    ///
    /// - Returns: Enum values of enciding type
    func parametersEncodingType() -> ParametersEncodingType?{
        return nil
    }
    
    /// Return what type of request is
    ///
    /// - Returns: Enums: rest,upload,uploadMultipart,download
    func taskType() -> TaskType{
        return .rest
    }
}
