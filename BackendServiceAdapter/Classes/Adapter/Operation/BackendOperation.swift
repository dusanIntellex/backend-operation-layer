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

public enum ResponseError : Error, Equatable{
    case noInternetConnection
    case requestCancel
    case authorizationError
    case serverMessageError(String)
    case unknownError
    case badRequest
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
        case .badRequest:
            return NSLocalizedString("Bad request", comment: "")
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
    
    lazy var executor: ExecutorProtocol = {
        switch request.executor(){
        case .alamofire:
            return AlamofireExecutor()
        case .urlSession:
            return URLSessionExecutor()
        default:
            return AlamofireExecutor()
        }
    }()
    
    var request: BackendRequest!
    
    public var onSuccess: BackendRequestSuccessCallback?
    public var onFailure: BackendRequestFailureCallback?
    
    // MARK:- Initilizer
    
    public init(_ request: BackendRequest) {
        super.init()
        self.request = request
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
        
        switch request.taskType() {
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
    
    private func handleSuccess(data: Any?, statusCode: NSInteger){
        if self.onSuccess != nil{
            handleData(data: data, statusCode: statusCode)
        }
        self.finish()
    }
    
    // Default data handler
    @objc dynamic public func handleData(data: Any?, statusCode: NSInteger){
        
        if 200 ... 299 ~= statusCode{
            self.onSuccess!(data, statusCode)
        }
        else if 300..<500 ~= statusCode{
            self.onFailure?(ResponseError.badRequest, statusCode)
        }
        else if 500...599 ~= statusCode{
            self.onFailure?(ResponseError.serverError, statusCode)
        }
        else{
            self.onFailure?(ResponseError.unknownError, statusCode)
        }
    }
    
    func handleFailure(error: Error?, statusCode: NSInteger){
        if self.onFailure != nil{
            self.onFailure!(error ?? ResponseError.unknownError , statusCode)
        }
        self.finish()
    }
}
