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

enum ResponseError : Error, Equatable{
    case noInternetConnection
    case requestCancel
    case authorizationError
    case serverMessageError(String)
    case unknownError
    case serverError
    case invalidData
    case verifyEmail
    case badLoginCredentials
    case invalidRegisterInputData([String])
}

extension ResponseError : LocalizedError{
    
    public var errorDescription: String?{
        switch self {
        case .noInternetConnection:
            return NSLocalizedString("No internet connection", comment: "")
        case .authorizationError:
            return NSLocalizedString("You are not authorized for this action", comment: "")
        case .serverMessageError(let message):
            return message
        case .unknownError:
            return NSLocalizedString("There is error. Please try again!", comment: "")
        case .serverError:
            return NSLocalizedString("We are currently working on this. Try again later.", comment: "")
        case .invalidData:
            return NSLocalizedString("Invalid data", comment: "")
        case .verifyEmail:
            return NSLocalizedString("Need to verify email", comment: "")
        case .badLoginCredentials:
            return NSLocalizedString("Invalid credentials", comment: "")
        case .invalidRegisterInputData(let errorList):
            return errorList.reduce("", { (result, nextError) -> String in
                var mutatingresult = result
                if mutatingresult.count > 0{
                    mutatingresult.append("'n'")
                }
                mutatingresult.append(nextError)
                return mutatingresult
            })
        case .requestCancel:
            return NSLocalizedString("Request cancel", comment: "")
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
    
    //MARK:- Start
    
    override public func execute() {
        
        // Check connection
        guard Reachability.isConnectedToNetwork() else{
            
            if (self.onFailure != nil){
                onFailure!(ResponseError.noInternetConnection,0)
            }
            
            self.finish()

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
            onFailure!(ResponseError.requestCancel,0)
        }
    }
    
    
    //MARK:- Callbacks
    
    func handleSuccess(data: Any?, statusCode: NSInteger){
        
        // TODO: For any special handling of status code, do this here!!
        if self.onSuccess != nil{
            
            if 200 ... 299 ~= statusCode{
                self.onSuccess!(data, statusCode)
            }
            else if statusCode == 400{
                self.onFailure?(ResponseError.badLoginCredentials, statusCode)
            }
            // Refresh token
            else if statusCode == 401{
                self.refreshToken()
                return
            }
            else if statusCode == 403{
                self.onFailure?(ResponseError.verifyEmail, statusCode)
            }
            else if statusCode >= 500{
                self.onFailure?(ResponseError.serverError, statusCode)
            }
            else{
                self.onFailure?(ResponseError.unknownError, statusCode)
            }
        }
        
        self.finish()
    }
    
    func handleFailure(error: Error?, statusCode: NSInteger){
        
        if self.onFailure != nil{
            self.onFailure!(error ?? ResponseError.unknownError , statusCode)
        }
        self.finish()
    }

    
    // MARK:- Special status code response handlers
    
    func refreshToken(){
        
        //Refresh token if there is need adn add it to handling status code
    }
}
