//
//  BackendRequestExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/14/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class URLSessionExecutor: NSObject, URLSessionTaskDelegate,URLSessionDelegate, URLSessionDownloadDelegate, ExecutorProtocol {
    
    enum Constant: String {
        case sessionID = "quantox.com.backgroundSession"
    }
    
    let timeoutInterval = 30.0
    private lazy var regularSession: URLSession = { [weak self] in
        
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        }()
    
    private lazy var backgroundSession: URLSession = { [weak self] in
        
        let config = URLSessionConfiguration.background(withIdentifier: Constant.sessionID.rawValue + ".\(Date().timeIntervalSince1970)")
        //        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
        }()
    
    var dataTask: URLSessionTask?
    weak var loadFile: FileLoad?
    var successCallback: BackendRequestSuccessCallback?
    var failureCallback: BackendRequestFailureCallback?
    
    func getSession(request: BackendRequest) -> URLSession{
        return (request as? BackgroundModeProtocol) != nil ? backgroundSession : regularSession
    }
    
    //MARK:- Execute
    
    func executeBackendRequest(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        let session = getSession(request: backendRequest)
        
        backendRequest.printRequest()
        
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if _isDebugAssertConfiguration(){
                print("""
                    \n---Response for request---
                    \(response?.url?.absoluteString ?? "unknown")\n
                    Status code:
                        \((response as! HTTPURLResponse).statusCode)
                    Result:
                    \(String(describing: try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)))
                    """)
            }
            
            if response == nil{
                failureCallback(ResponseError.serverError, 0)
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
                failureCallback(error!, statusCode)
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
        
        // File located on disk
        guard backendRequest.taskType() == .download, let fileId = (backendRequest as? DownloadFileProtocol)?.fileId else {
            fatalError("You have not set file id within request. Backend request: \(backendRequest.route()) need to implement Download File protocol")
        }
        
        let session = getSession(request: backendRequest)
        self.loadFile = FilesPool.sharedInstance.getFile(fileId: fileId)
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        backendRequest.printRequest()
        
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
        
        guard backendRequest.taskType() == .upload, let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            fatalError("You have not set file id within request. Backend request: \(backendRequest.route()) need to implement Download File protocol")
        }
        
        let session = getSession(request: backendRequest)
        let request = self.requestWithBackendRequest(backendRequest: backendRequest)
        
        self.loadFile = file
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        guard let tempURL = file.path else{
            if _isDebugAssertConfiguration(){
                print("Can not create temp url path!. Upload file: \(file.fileId ?? "")")
            }
            failureCallback(BackendRequestError.errorCreatingTempFile, 1001)
            return
        }
        
        backendRequest.printRequest()
        
        self.dataTask = session.uploadTask(with: request, fromFile: tempURL)
        self.dataTask?.resume()
    }
    
    func uploadMultipart(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        guard backendRequest.taskType() == .upload, let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            fatalError("You have not set file id within request. Backend request: \(backendRequest.route()) need to implement Download File protocol")
        }
        
        guard let tempURL = file.path else{
            if _isDebugAssertConfiguration(){
                print("Can not create temp url path!. Upload file: \(file.fileId ?? "")")
            }
            failureCallback(BackendRequestError.errorCreatingTempFile, 1001)
            return
        }
        
        guard let data = try? Data(contentsOf: tempURL) else{
            if _isDebugAssertConfiguration(){
                print("Can not get data from url path - \(tempURL). Upload file: \(file.fileId ?? "")")
            }
            failureCallback(BackendRequestError.errorCreatingTempFile, 1001)
            return
        }
        
        var request = requestWithBackendRequest(backendRequest: backendRequest)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let params = getParams(backendRequest: backendRequest)
        
        request.httpBody = createBody(parameters: params, boundary: boundary, data: data, mimeType: file.mimeType ?? "image/jpg", name: file.dataName ?? "image", filename: file.dataFilename ?? "untitled")
        
        let session = getSession(request: backendRequest)
        
        self.loadFile = file
        self.successCallback = successCallback
        self.failureCallback = failureCallback
        
        backendRequest.printRequest()
        
        self.dataTask = session.uploadTask(with: request as URLRequest, fromFile: tempURL)
        self.dataTask?.resume()
    }
    
    //MARK:- Private
    
    private func requestWithBackendRequest(backendRequest: BackendRequest) -> URLRequest{
        let url = getUrl(backendRequest: backendRequest)
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        request.httpMethod = backendRequest.method().rawValue
        // Set header for specific server
        setHeaders(backendRequest: backendRequest, for: request)
        
        // Get params
        let params = getParams(backendRequest: backendRequest)
        if let encodingType = backendRequest.parametersEncodingType(){
            setParams(type: encodingType, params: params, request: request)
        }
        
        return request as URLRequest
    }
    
    private func getUrl(backendRequest: BackendRequest) -> URL{
        let baseUrlString = backendRequest.baseUrl()
        let route = backendRequest.route()
        guard let baseUrl = URL(string: baseUrlString) else{
            fatalError("Endpoint could not be created from base url \"\(baseUrlString)\" and route \"\(route)\"")
        }
        return baseUrl.appendingPathComponent(route)
    }
    
    private func setHeaders(backendRequest: BackendRequest, for request:NSMutableURLRequest){
        // Set header for specific server
        for value in COMMON_HEADERS{
            request.setValue(value.value, forHTTPHeaderField: value.key)
        }
        // Custom headers
        if let headers = backendRequest.headers(){
            for pair in headers {
                request.setValue(pair.value, forHTTPHeaderField: pair.key)
            }
        }
    }
    
    private func getParams(backendRequest: BackendRequest) -> [String : Any]{
        return backendRequest.params() ?? [String : Any]()
    }
    
    private func setParams(type: ParametersEncodingType, params: [String: Any], request: NSMutableURLRequest){
        switch type{
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
            if let data = encodeUrlParams(requestParams: params).data(using: .utf8){
                request.httpBody = data
            }
            else{
                print("Not able to create base64 data from params")
            }
            break
            
        case .urlEncode:
            let urlComponents = NSURLComponents(string: request.url!.absoluteString)
            urlComponents?.queryItems = params.map{ URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
            request.url = urlComponents?.url
            break
        }
    }
    
    private func createBody(parameters: [String: Any]?,
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    name: String,
                    filename: String) -> Data {
        
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if let param = parameters{
            for (key, value) in param {
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\("\(value)"))\r\n")
            }
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    private func encodeUrlParams(requestParams: [String: Any]) -> String{
        
        var urlParamsEncode = "?"
        
        for (key, value) in requestParams{
            if urlParamsEncode.count > 1 { urlParamsEncode.append("&")}
            urlParamsEncode.append(key)
            urlParamsEncode.append("=")
            urlParamsEncode.append(String(describing: value))
        }
        
        let allowedCharacters = NSCharacterSet.urlQueryAllowed
        if let encodedString = urlParamsEncode.addingPercentEncoding(withAllowedCharacters: allowedCharacters){
            return encodedString
        }
        
        return urlParamsEncode
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
    
    //MARK:- Session delegate for tracking upload and download progress
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.loadFile?.progress = CGFloat(uploadProgress)
        self.loadFile?.status = .progress
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let downloadProgress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.loadFile?.progress = CGFloat(downloadProgress)
        self.loadFile?.status = .progress
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 1001
        
        if error != nil{
            self.loadFile?.status = .fail
            self.failureCallback?(error!, statusCode)
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
            self.failureCallback?(downloadTask.error!, statusCode!)
            return
        }
        
        if downloadTask.response == nil{
            self.loadFile?.status = .fail
            self.failureCallback?(BackendRequestError.errorDownloadingFile, 1001)
            return;
        }
        
        if let path = self.loadFile?.path {
            do {
                if FileManager.default.fileExists(atPath: path.relativePath){
                    try FileManager.default.removeItem(at: path)
                }
                try FileManager.default.copyItem(at: location, to: path)
                self.loadFile!.status = .success
                self.successCallback?(self.loadFile, statusCode!)
            } catch {
                print("error writing file \(path)",error.localizedDescription)
                self.loadFile!.status = .fail
                self.failureCallback?(error, statusCode!)
            }
        }
        else{
            fatalError("No file path for file \(self.loadFile?.fileId ?? "- Load file probaly deinit")")
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        /*
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
         */
        
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
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}


