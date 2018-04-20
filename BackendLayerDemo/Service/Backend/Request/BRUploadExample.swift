//
//  BRUploadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GoogleSignIn

class BRUploadExample : BackendRequest, UploadFileProtocol {
    
    var uploadFile: FileLoad?
    
    func endpoint() -> String {
        return "https://www.googleapis.com/upload/drive/v3/files?uploadType=media"
//        return "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
    }
    
    func method() -> HttpMethod {
        return .post
    }
    
    func headers() -> Dictionary<String, String>? {
        let token = GIDSignIn.sharedInstance().currentUser.authentication.accessToken ?? ""
        print(token)
        return ["Authorization" : "Bearer \(token)",
                "Content-Type": "image/jpeg"]
    }
    
    func requestType() -> RequestType? {
        return .upload
    }
    
    func encodingType() -> ParametersEncodingType? {
        return nil
    }
    
}
