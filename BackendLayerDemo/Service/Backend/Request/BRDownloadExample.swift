//
//  BRDownloadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class BRDownloadExample: NSObject, BackendRequest, DownloadFileProtocol {
    func downloadFileId() -> String? {
        return "test"
    }
    
    
    func endpoint() -> String {
        return "http://trailers.divx.com/divx_prod/profiles/Helicopter_DivXHT_ASP.divx"
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
    
    func firebaseObserver() -> Bool? {
        return nil
    }
    
    func encodingType() -> ParametersEncodingType? {
        return nil
    }
    
    func createBody() -> Data? {
        return nil
    }
}
