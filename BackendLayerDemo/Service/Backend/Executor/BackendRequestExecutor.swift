//
//  BackendRequestExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/14/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class BackendRequestExecutor: NSObject, URLSessionTaskDelegate,URLSessionDelegate, URLSessionDownloadDelegate, BackendExecutorProtocol {
    
    enum Constant: String {
        case sessionID = "quantox.com.BackendLayerDemo.bgSession"
    }
    
    let timeoutInterval = 60.0
    private lazy var regularSession: URLSession = { [unowned self] in

        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }()
    
    private lazy var backgroundSession: URLSession = { [unowned self] in
        let config = URLSessionConfiguration.background(withIdentifier: Constant.sessionID.rawValue + ".\(Date().timeIntervalSince1970)")
//        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    var dataTask: URLSessionTask?
    var loadFile: FileLoad?
    var successCallback: BackendRequestSuccessCallback?
    var failureCallback: BackendRequestFailureCallback?
    
    func getSession(request: BackendRequest) -> URLSession{
        
        return request.background() ? backgroundSession : regularSession
    }
    
    //MARK:- Execute
    
    func executeBackendRequest(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        let session = getSession(request: backendRequest)
        
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
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
        
        guard let fileId = (backendRequest as? DownloadFileProtocol)?.fileId else {
            if _isDebugAssertConfiguration(){
                print("You have not set file id within request. Backend request: \(backendRequest.endpoint()) need to implement Download File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        let session = getSession(request: backendRequest)
        
        self.loadFile = FileLoad.getFile(fileId: fileId, data: nil)
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        dataTask = session.downloadTask(with: request)
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
        
        guard let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            if _isDebugAssertConfiguration(){
                print("You have not set file id within request. Backend request: \(backendRequest.endpoint()) need to implement Download File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        let session = getSession(request: backendRequest)
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        self.loadFile = file
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        if let tempURL = copyFileTemporaryDirectory(file: file.data!, fileExtension: file.fileExtension!){
            self.dataTask = session.uploadTask(with: request, fromFile: tempURL) // session.uploadTask(with: request, from: file.data!)
            self.dataTask?.resume()
        }
    }
    
    func uploadMultipart(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        guard let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            if _isDebugAssertConfiguration(){
                print("You have not set file id within request. Backend request: \(backendRequest.endpoint()) need to implement Download File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        let urlString = SERVER_URL.appending(backendRequest.endpoint())
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        request.httpMethod = backendRequest.method().rawValue
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let params = backendRequest.paramteres()
        request.httpBody = createBody(parameters: params as? [String : String], boundary: boundary, data: file.data!, mimeType: file.mimeType ?? "", filename: file.name ?? "untitled")
        
        let session = getSession(request: backendRequest)
        
        self.loadFile = file
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        if let tempURL = copyFileTemporaryDirectory(file: file.data!, fileExtension: file.fileExtension!){
            self.dataTask = session.uploadTask(with: request as URLRequest, fromFile: tempURL) // session.uploadTask(with: request, from: file.data!)
            self.dataTask?.resume()
        }
    }
    
    func createBody(parameters: [String: String]?,
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if let param = parameters{
            for (key, value) in param {
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
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
        print("\nBackend executor Upload Progres: \(uploadProgress)\n")
        
        if let file = self.loadFile {
            
            file.progress = CGFloat(uploadProgress)
            self.loadFile?.status = .progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let downloadProgress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("\nBackend executor Download Progres: \(downloadProgress)\n")
        
        if let file = self.loadFile {
            
            file.progress = CGFloat(downloadProgress)
            self.loadFile?.status = .progress
        }
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 1001
        
        if error != nil{
            self.loadFile?.status = .fail
        
            self.failureCallback?(error, statusCode)
            return
        }
        
        if task.isKind(of: URLSessionUploadTask.self) {
            self.loadFile?.status = .success
            self.successCallback?(self.loadFile, statusCode)
        }
        
        session.finishTasksAndInvalidate()
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
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        DispatchQueue.main.async {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.bgSessionCompletionHandler
                else {
                    return
            }
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()
        }

        /*
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            
            guard appDelegate.responds(to: Selector(("bgSessionCompletionHandler"))) else{
                assertionFailure("Implement bgSessionCompletionHandler in AppDelegate")
                return
            }
            
            var property = AppDelegate.value(forKey: "bgSessionCompletionHandler")
            let completionHandler = NSSelectorFromString("AppDelegate.bgSessionCompletionHandler")

            DispatchQueue.main.async {
                
                property = nil
                self.perform(completionHandler)
            }
        }
    */
    }
    
    func copyFileTemporaryDirectory(file: Data, fileExtension: String ) -> URL?
    {
        
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        
        // Create a destination URL.
        let targetURL = tempDirectoryURL.appendingPathComponent("temp.\(fileExtension)")
        
        // Copy the file.
        do {
            try file.write(to: targetURL)
            return targetURL
        } catch let error {
            NSLog("Unable to copy file: \(error)")
        }
        return nil
    }
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

