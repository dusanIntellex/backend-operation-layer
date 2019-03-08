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

    var uploadFile: FileLoad?
    
    func endpoint() -> String {
        //        return "https://www.googleapis.com/upload/drive/v3/files?uploadType=media"
        return "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
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
    
    func requestType() -> RequestType? {
        return .upload
    }
    
    func params() -> [String : Any]? {
        return nil
    }
    
    func encodingType() -> ParametersEncodingType? {
        return nil
    }
}
