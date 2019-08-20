//
//  BRDownloadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter

class BRDownloadExample: BackendRequest, DownloadFileProtocol, BackgroundModeProtocol{
    
    var fileId: String
    required init(fileId: String) {
        self.fileId = fileId
    }
    
    func executor() -> RequestExecutorType {
        return .urlSession
    }
    
    func baseUrl() -> String {
        return "http://ipv4.download.thinkbroadband.com"
    }
    
    func route() -> String {
        return "5MB.zip"
    }
    
    func method() -> HttpMethod {
        return .get
    }
    
    func headers() -> Dictionary<String, String>? {
        return nil
    }
    
    func taskType() -> TaskType {
        return .download
    }
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func parametersEncodingType() -> ParametersEncodingType? {
        return nil
    }
}
