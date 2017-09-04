//
//  BackendRequestExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/14/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class BackendRequestExecutor: NSObject, URLSessionTaskDelegate {
    
    var session: URLSession?{
        
        get{
            
            return URLSession.shared
        }
    }
    
    var dataTask: URLSessionTask?
    var loadFile: FileLoad?
    var successCallback: BackendRequestSuccessCallback?
    var failureCallback: BackendRequestFailureCallback?
    
    
    //MARK:- Execute
    
    func executeBackendRequest(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        dataTask = self.session?.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if response == nil{
                failureCallback(nil, 0)
                return;
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if data != nil{
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    successCallback(json, statusCode)
                    return;
                }
                catch{
                    successCallback(nil, statusCode)
                    return;
                }
            }
            
            if error != nil{
                failureCallback(error, statusCode)
            }
        })
        
        dataTask?.resume()
    }
    
    /// Download file
    ///
    /// - Parameters:
    ///   - backendRequest: <#backendRequest description#>
    ///   - successCallback: <#successCallback description#>
    ///   - failureCallback: <#failureCallback description#>
    func downloadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback) {
        
        guard let fileId = backendRequest.paramteres()?[BRFileIdConst] else {
            failureCallback(nil, 1001)
            return
        }
        
        // File located on disk
        let file = FileLoad.getFile(fileId: fileId as! String, data: NSData())
        self.loadFile = file
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        self.dataTask = session?.downloadTask(with: request) { (tempLocalUrl, response, error) in
            
            if response == nil{
                
                // Restart callback to not 2 times return error
                self.failureCallback = nil
                failureCallback(nil, 1001)
                return;
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            if let tempLocalUrl = tempLocalUrl, error == nil {
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: file.path!)
                    self.successCallback = nil
                    successCallback(tempLocalUrl, statusCode!)
                } catch (let writeError) {
                    print("error writing file \(file.path!) : \(writeError)")
                    self.failureCallback = nil
                    failureCallback(writeError, statusCode!)
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription as Any);
                self.failureCallback = nil
                failureCallback(error, statusCode!)
            }
        }
        
        dataTask?.resume()
    }
    
    /// Upload file with unique file id, data to be uplaoded, headers and completion block. Upload progress and status is tracked on file which containe all data about upload progress
    ///
    /// - Parameters:
    ///   - fileId: Id of file
    ///   - data: File data
    ///   - headers: Header for upload
    ///   - successCallback: Return data and status code
    ///   - failureCallback: Return error and stts code
    func uploadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback) {
        
        guard let fileId = backendRequest.paramteres()?[BRFileIdConst] else {
            failureCallback(nil, 1001)
            return
        }
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        // File located on disk
        let file = FileLoad.getFile(fileId: fileId as! String, data: nil)
        self.loadFile = file
        
        self.dataTask = session?.uploadTask(with: request, fromFile: file.path!, completionHandler: { (data, response, error) in
            
            if response == nil{
                failureCallback(nil, 1001)
                return;
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            if response != nil, error == nil {
                
                successCallback(response, statusCode!)
                
            } else {
                print("Failure: %@", error?.localizedDescription as Any);
                failureCallback(error, statusCode!)
            }
        })
        
        self.dataTask?.resume()
    }

    
    func requestWithBackendRequest(backendRequest: BackendRequest) -> URLRequest{
        
        let urlString = SERVER_URL.appending(backendRequest.endpoint())
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = backendRequest.method().rawValue
        
        // Set header for specific server
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ios", forHTTPHeaderField: "Client-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let headers = backendRequest.headers(){
        
            for dict in headers {
                
                request.setValue(dict.value, forHTTPHeaderField: dict.key)
            }
        }
        
        // Set params
        if let params = backendRequest.paramteres(){
            
            do{
                let jsonParams = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                request.httpBody = jsonParams
            }
            catch{
                print(error.localizedDescription)
            }
        }
        
        print("\n\nService request:\nEndpoint:\(backendRequest.endpoint())\nHeaders:\(String(describing: request.allHTTPHeaderFields))\nParams:\(String(describing: backendRequest.paramteres()))")
        
        return request as URLRequest
    }
    
    
    // MARK: - Task manage
    
    func cancel(){
        self.dataTask?.cancel()
    }
    
    func resume(){
        self.dataTask?.resume()
    }
    
    func pause(){
        self.dataTask?.suspend()
    }
    

    // TODO: Track progress and file status!!
    //MARK:- Session delegate

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print(uploadProgress)
        
        if let file = self.loadFile {
            
            file.progress = CGFloat(uploadProgress)
        }
    }
    
}
