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

enum ResponseError : Error{
    case noInternetConnection
}

extension ResponseError : LocalizedError{
    
    public var errorDescription: String?{
        switch self {
        case .noInternetConnection:
            return NSLocalizedString("No internet connection", comment: "")
        }
    }
}

public class BackendOperation: AsyncOperation {
    
    lazy var executor: BackendExecutorProtocol = {
        return BackendAlamofireExecutor()
//        return BackendRequestExecutor()
    }()
    
    var request: BackendRequest?
    
    public var onSuccess: BackendRequestSuccessCallback?
    public var onFailure: BackendRequestFailureCallback?
    
    // MARK:- Initilizer
    
    public init(model: Encodable?, request: BackendRequest?) {
        super.init()

        self.request = request

        if let req = request as? ManagePostDataProtocol, model != nil{
            req.setSendingData(data: model!)
        }
    }


    public init(model: Encodable?, request: BackendRequest?,_ uploadFile: FileLoad?) {
        super.init()

        self.request = request
        
        if let req = request as? ManagePostDataProtocol, model != nil{
            req.setSendingData(data: model!)
        }
        
        if let _ = request as? UploadFileProtocol, uploadFile != nil{
            (self.request as! UploadFileProtocol).uploadFile = uploadFile!
        }
    }

    
    func isSingleton() -> Bool{
        
        return false
    }
    
    //MARK:- Start
    
    override public func execute() {
        
        // Check connection
        guard Reachability.isConnectedToNetwork() else{
            
            if (self.onFailure != nil){
                onFailure!(ResponseError.noInternetConnection,0)
            }
            
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
        self.executor.executeBackendRequest(backendRequest: self.request!, successCallback: { [weak self] (data, code) in
            self?.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { [weak self] (error, code) in
            self?.handleFailure(error: error, statusCode: code)
        })
    }
    
    func upload() {
        
        self.executor.uploadFile(backendRequest: self.request!, successCallback: { [weak self] (data, code) in
            self?.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { [weak self] (error, code) in
            self?.handleFailure(error: error, statusCode: code)
        })
    }
    
    func uploadMultipart(){
        
        self.executor.uploadMultipart(backendRequest: self.request!, successCallback: { [weak self] (data, code) in
            self?.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { [weak self] (error, code) in
            self?.handleFailure(error: error, statusCode: code)
        })
    }
    
    func download() {
        
        self.executor.downloadFile(backendRequest: self.request!, successCallback: { [weak self] (data, code) in
            self?.handleSuccess(data: data, statusCode: code)
        }, failureCallback: { [weak self] (error, code) in
            self?.handleFailure(error: error, statusCode: code)
        })
    }
    
    //MARK:- Cancel
    
    override public func cancel() {
        
        self.executor.cancel()
        
        if (self.onFailure != nil){
            onFailure!(nil,0)
        }
    }
    
    
    //MARK:- Callbacks
    
    func handleSuccess(data: Any?, statusCode: NSInteger){
        
        DispatchQueue.main.async { [weak self] in
            
            
            // TODO: For any special handling of status code, do this here!!
            if self?.onSuccess != nil{
                
                if 200 <= statusCode && statusCode < 300{
        
                    self?.onSuccess!(data, statusCode)
                }
                else{
                    self?.onSuccess!(nil, statusCode)
                }
            }
            
            self?.finish()
        }
    }
    
    func handleFailure(error: Error?, statusCode: NSInteger){
        
        DispatchQueue.main.async { [weak self] in
            
            if self?.onFailure != nil{
                
                self?.onFailure!(error, statusCode)
            }
        }
        
        self.finish()
    }

    
    // MARK:- Special status code response handlers
    
    func refreshToken(){
        
        //TODO: refresh token if there is need adn add it to handling status code
    }
}
