//
//  BackendRequestExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/14/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class BackendRequestExecutor: NSObject, URLSessionTaskDelegate,URLSessionDelegate, URLSessionDownloadDelegate, BackendExecutorProtocol {
    
    
    let timeoutInterval = 60.0
    var session: URLSession?{
        
        get{
            let config = URLSessionConfiguration.default
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
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
                }
                catch{
                    successCallback(nil, statusCode)
                }
                return
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
        
        guard let fileId = (backendRequest as? DownloadFileProtocol)?.downloadFileId() else {
            if _isDebugAssertConfiguration(){
                print("You have not set file id within request. Backend request: \(backendRequest.endpoint()) need to implement Download File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        // File located on disk
        self.loadFile = FileLoad.getFile(fileId: fileId, data: nil)
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        self.dataTask = session?.downloadTask(with: request)
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
        
        let request = NSMutableURLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        request.httpMethod = backendRequest.method().rawValue
        
        // Set header for specific server
        _ = COMMON_HEADERS.map{
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        if let headers = backendRequest.headers(){
            
            for dict in headers {
                
                request.setValue(dict.value, forHTTPHeaderField: dict.key)
            }
        }
        
        // Set params
        if let encodingType = backendRequest.encodingType(), let params = backendRequest.paramteres(){
            
            switch encodingType{
                
            case .jsonBody:
                do{
                    let jsonParams = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    request.httpBody = jsonParams
                }
                catch{
                    print(error.localizedDescription)
                }
                break
                
            case .multipartBodyURLEncode:
                
                if let data = encodeUrlParams(request: backendRequest).data(using: .utf8){
                    request.httpBody = data
                }
                else{
                    print("Not able to create base64 data from params")
                }
                
                break
                
            case .urlEncode:
                let urlString = (request.url?.absoluteString)! + encodeUrlParams(request: backendRequest)
                request.url = URL(string: urlString)
                break
                
            case .customBody:
                if let body = backendRequest.createBody(){
                    request.httpBody = body
                }
                break
            }
        }
            
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
    
    private func encodeUrlParams(request: BackendRequest) -> String{
        
        var urlParamsEncode = "?"
        if let params = request.paramteres(){
            
            for (key, value) in params{
                if urlParamsEncode.count > 1 { urlParamsEncode.append("&")}
                urlParamsEncode.append(key)
                urlParamsEncode.append("=")
                urlParamsEncode.append(String(describing: value))
            }
        }
        
        let allowedCharacters = NSCharacterSet.urlQueryAllowed
        if let encodedString = urlParamsEncode.addingPercentEncoding(withAllowedCharacters: allowedCharacters){
            return encodedString
        }
        
        return urlParamsEncode
    }

    //MARK:- Session delegate for tracking upload and download progress

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print("\nBackend executor UploadProgres: \(uploadProgress)\n")
        
        if let file = self.loadFile {
            
            file.progress = CGFloat(uploadProgress)
            self.loadFile?.status = .progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let downloadProgress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("\nBackend executor UploadProgres: \(downloadProgress)\n")
        
        if let file = self.loadFile {
            
            file.progress = CGFloat(downloadProgress)
            self.loadFile?.status = .progress
        }
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil{
            self.loadFile?.status = .fail
            let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 1001
            self.failureCallback?(error, statusCode)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        let statusCode = (downloadTask.response as? HTTPURLResponse)?.statusCode
        
        guard downloadTask.error == nil else{
            self.loadFile?.status = .fail
            self.failureCallback?(downloadTask.error, statusCode!)
            return
        }
        
        if downloadTask.response == nil{
            self.failureCallback?(nil, 1001)
            return;
        }
        
        if let file = self.loadFile {
            
            if file.path != nil{
                do {
                    if FileManager.default.fileExists(atPath: file.path!.path){
                        do{
                            try FileManager.default.removeItem(at: file.path!)
                        }
                        catch{
                            self.failureCallback?(error, statusCode!)
                            return
                        }
                    }
                    
                    try FileManager.default.copyItem(at: location, to: file.path!)
                    self.successCallback?(file, statusCode!)
                } catch (let writeError) {
                    print("error writing file \(file.path!) : \(writeError)")
                    self.failureCallback?(writeError, statusCode!)
                }
            }
            else{
                file.path = location
                self.successCallback?(file, statusCode!)
            }
        }
        else{
            self.successCallback?(nil, statusCode!)
        }
        self.loadFile?.status = .success
    }
}
