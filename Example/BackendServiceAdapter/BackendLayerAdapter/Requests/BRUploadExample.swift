//
//  BRUploadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter

class BRUploadExample : BackendRequest, UploadFileProtocol{

    var uploadFile: UploadFile!
    required init(fileId: String, filePath: URL, name: String, type: String, fileExtension: String) {
        self.uploadFile = UploadFile(filePath: filePath, fileId: fileId, name: name, type: type, fileExtension: fileExtension)
    }
    
    
    
    func baseUrl() -> String {
        return "https://www.bidbeds.com/api/v1"
    }
    
    func route() -> String {
        return "user/84/image"
    }
    
    func method() -> HttpMethod {
        return .post
    }
    
    func headers() -> Dictionary<String, String>? {
        return ["Authorization" : "Bearer 8d10192eb4f3bbad57882278841350b5ccfb9768"]
    }
    
    func taskType() -> TaskType {
        return .upload
    }
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func parametersEncodingType() -> ParametersEncodingType? {
        return nil
    }
}
