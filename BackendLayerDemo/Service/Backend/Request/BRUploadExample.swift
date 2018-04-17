//
//  BRUploadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GoogleSignIn

class BRUploadExample: NSObject , BackendRequest, UploadFileProtocol {
    
    var uploadFileObject: FileLoad?
    
    init(uploadFile: FileLoad) {
        super.init()
        
        self.uploadFileObject = uploadFile
    }
    
    func endpoint() -> String {
        return "https://www.googleapis.com/upload/drive/v3/files?uploadType=media"
    }
    
    func method() -> HttpMethod {
        return .post
    }
    
    func paramteres() -> Dictionary<String, Any>? {
        return nil
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
    
    func firebaseObserver() -> Bool? {
        return nil
    }
    
    func encodingType() -> ParametersEncodingType? {
        return nil
    }
    
    func createBody() -> Data? {
        return nil
    }
    
    func uploadFile() -> FileLoad? {
        return self.uploadFileObject
    }
    

    
}
