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
    
    var uploadFile: UploadFile?
    
    func baseUrl() -> String {
        return "https://www.googleapis.com"
    }
    
    func route() -> String {
        return "upload/drive/v3/files"
        //        return "https://www.googleapis.com/?uploadType=media"
//        return "/upload/drive/v3/files?uploadType=multipart"
    }
    
    func method() -> HttpMethod {
        return .post
    }
    
    func headers() -> Dictionary<String, String>? {
        //        let token = GIDSignIn.sharedInstance().currentUser.authentication.accessToken ?? ""
        //        print(token)
        return ["Authorization" : "Bearer \("token")",
            "Content-Type": "multipart/related; boundary=foo_bar_baz"]
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
