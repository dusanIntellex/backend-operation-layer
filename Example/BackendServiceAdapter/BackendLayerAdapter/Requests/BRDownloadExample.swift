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
    
    init() {
        self.fileId = "downloadFile\(Date().timeIntervalSince1970)"
    }
    
    func endpoint() -> String {
        return "http://ipv4.download.thinkbroadband.com/5MB.zip"
    }
    
    func method() -> HttpMethod {
        return .get
    }
    
    func headers() -> Dictionary<String, String>? {
        return nil
    }
    
    func requestType() -> RequestType? {
        return .download
    }
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func encodingType() -> ParametersEncodingType? {
        return nil
    }
}
/*
class BRDownloadExample: BackendRequest, DownloadFileProtocol, BackgroundModeProtocol {
    
    var fileId: String

    init() {
        self.fileId = "downloadFile\(Date().timeIntervalSince1970)"
    }
    
    
    func endpoint() -> String {
        return "http://ipv4.download.thinkbroadband.com/5MB.zip" 
    }
    
    func method() -> HttpMethod {
        return .get
    }
    
    func paramteres() -> Dictionary<String, Any>? {
        return nil
    }
    
    func headers() -> Dictionary<String, String>? {
        return nil
    }
    
    func requestType() -> RequestType? {
        return .download
    }
}
*/
