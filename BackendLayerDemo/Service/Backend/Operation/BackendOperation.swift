//
//  BackendOperation.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

/*
                                                ***IMPORTANT***
 
 To use different backend executors (Firebase, native iOS URLSession, Alamofire) just change class of executor
*/

class BackendOperation: AsyncOperation {
    
    lazy var executor: BackendRequestExecutor = {
        return BackendRequestExecutor()//BackendAlamofireExecutor()
    }()
    
    var request: BackendRequest?
    
    var onSuccess: BackendRequestSuccessCallback?
    var onFailure: BackendRequestFailureCallback?
    
    // MARK:- Initilizer
    
    init(model: BaseModel?, request: BackendRequest?) {
        super.init()

        self.request = request
        
        if let _ = request as? SendingDataProtocol, model != nil{
            (self.request as! SendingDataProtocol).sendingModel = model!
        }
    }


    init(model: BaseModel?, request: BackendRequest?,_ uploadFile: FileLoad?) {
        super.init()

        self.request = request
        
        if let _ = request as? SendingDataProtocol, model != nil{
            (self.request as! SendingDataProtocol).sendingModel = model!
        }
        
        if let _ = request as? UploadFileProtocol, uploadFile != nil{
            (self.request as! UploadFileProtocol).uploadFile = uploadFile!
        }
    }

    
    func isSingleton() -> Bool{
        
        return false
    }
    
    //MARK:- Start
    
    override func execute() {
        
        // Check connection
        guard Reachability.isConnectedToNetwork() else{
            self.finish()
            // TODO: Handle internet connection
            return
        }
        
        guard let type = request!.requestType()  else { rest(); return }
        
        switch type {
        case .rest:
            rest()
            break
        case .download:
            download()
            break
        case .upload:
            upload()
            break
        case .uploadMultipart:
            uploadMultipart()
            break
        }
    }
    
    func rest(){
        self.executor.executeBackendRequest(backendRequest: self.request!, successCallback: { (data, code) in
            self.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { (error, code) in
            self.handleFailure(error: error, statusCode: code)
        })
    }
    
    func upload() {
        
        self.executor.uploadFile(backendRequest: self.request!, successCallback: { (data, code) in
            self.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { (error, code) in
            self.handleFailure(error: error, statusCode: code)
        })
    }
    
    func uploadMultipart(){
        
        self.executor.uploadMultipart(backendRequest: self.request!, successCallback: { (data, code) in
            self.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { (error, code) in
            self.handleFailure(error: error, statusCode: code)
        })
    }
    
    func download() {
        
        self.executor.downloadFile(backendRequest: self.request!, successCallback: { (data, code) in
            self.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { (error, code) in
            self.handleFailure(error: error, statusCode: code)
        })
    }
    
    //MARK:- Cancel
    
    override func cancel() {
        
        self.executor.cancel()
        
        if (self.onFailure != nil){
            onFailure!(nil,0)
        }
    }
    
    
    //MARK:- Callbacks
    
    func handleSuccess(data: Any?, statusCode: NSInteger){
        
        DispatchQueue.main.async {
            
            
            // TODO: For any special handling of status code, do this here!!
            if self.onSuccess != nil{
                
                if statusCode == 200{
        
                    self.onSuccess!(data, statusCode)
                }
                else{
                    self.onSuccess!(nil, statusCode)
                }
            }
            
            self.finish()
        }
    }
    
    func handleFailure(error: Error?, statusCode: NSInteger){
        
        DispatchQueue.main.async {
            
            if self.onFailure != nil{
                
                self.onFailure!(error, statusCode)
            }
        }
        
        self.finish()
    }

    
    // MARK:- Special status code response handlers
    
    func refreshToken(){
        
        //TODO: refresh token if there is need adn add it to handling status code
    }
}
