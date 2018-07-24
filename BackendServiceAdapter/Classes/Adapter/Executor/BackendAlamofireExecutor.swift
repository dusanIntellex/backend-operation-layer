//
//  BackendAlamofireExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import Alamofire

class BackendAlamofireExecutor: NSObject, BackendExecutorProtocol {

    enum Constant: String {
        case sessionID = "quantox.com.BackendLayerDemo.bgSession"
    }
    
    let timeoutInterval = 60.0
    private lazy var regularSession: SessionManager = { [unowned self] in
        
        let config = URLSessionConfiguration.default
        return Alamofire.SessionManager(configuration: config)
        }()
    
    private lazy var backgroundSession: SessionManager = { [unowned self] in
        let config = URLSessionConfiguration.background(withIdentifier: Constant.sessionID.rawValue + ".\(Date().timeIntervalSince1970)")
        //        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return Alamofire.SessionManager(configuration: config)
        }()
    
    func getSession(request: BackendRequest) -> SessionManager{
        
        return (request as? BackgroundModeProtocol) != nil ? backgroundSession : regularSession
    }
    
    var dataTask : Request?
    
    //MARK:- Execute
    
    /// Execute REST request with predefined endpoint, params and method
    ///
    /// - Parameters:
    ///   - backendRequest: Request
    ///   - successCallback: Return data and status code
    ///   - failureCallback: Return error and stts code
    func executeBackendRequest(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = self.getHeader(backendRequest: backendRequest)
        let encoding = self.getEncodingType(backendRequest: backendRequest)
        let params = self.getParams(backendRequest: backendRequest)
        
        if _isDebugAssertConfiguration(){
            print("\nBackend service request:\nEndpoint:\(backendRequest.endpoint())\nURL:\(url.absoluteString)\nMethod:\(method.rawValue)\nEncoding:\(encoding)\nHeaders:\(headers))\nParams:\(String(describing: params))")
        }
        
        dataTask = getSession(request: backendRequest).request(url, method: method, parameters: params, encoding:  encoding, headers:headers).responseJSON { (response:DataResponse<Any>) in
            
            let statusCode = response.response?.statusCode
            
            if response.result.isSuccess{
                
                if let data = response.result.value{
                    
                    successCallback(data, statusCode ?? 0)
                }
                else{
                    
                    successCallback(nil, statusCode ?? 0)
                }
            }
            else{
                
                failureCallback(response.error,statusCode ?? 0)
            }
        }
        
        dataTask?.task?.resume()
    }
    
    
    /// Donwload file
    ///
    /// - Parameters:
    ///   - backendRequest: <#backendRequest description#>
    ///   - successCallback: <#successCallback description#>
    ///   - failureCallback: <#failureCallback description#>
    func downloadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback) {
        
        // File located on disk
        guard let fileId = (backendRequest as? DownloadFileProtocol)?.fileId else {
            if _isDebugAssertConfiguration(){
                print("You have not set file id within request. Backend request: \(backendRequest.endpoint()) need to implement Download File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        let file = FileLoad.getFile(fileId: fileId, data: nil)
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = self.getHeader(backendRequest: backendRequest)
        let params = self.getParams(backendRequest: backendRequest)
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(fileId)")
            
            file.path = fileURL
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        self.dataTask = getSession(request: backendRequest).download(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers, to: destination).downloadProgress(closure: { (progress) in
            
            //progress closure
                file.status = .progress
                file.progress = CGFloat(progress.fractionCompleted)
                
            }).responseString { response in
                
                file.status = response.result.isSuccess ? .success : .fail
                
                // If success
                if response.result.isSuccess{
                    
                    successCallback(file, (response.response?.statusCode)!)
                    
                } else {
                    if _isDebugAssertConfiguration(){
                        print("error downloading file - \(String(describing: response.error?.localizedDescription))")
                    }
                    failureCallback(response.result.error, response.response?.statusCode ?? -1001)
                }
        }
    }
    

    /// Upload request. FileUpload has status and progress which can be tracked
    ///
    /// - Parameters:
    ///   - backendRequest: <#backendRequest description#>
    ///   - successCallback: <#successCallback description#>
    ///   - failureCallback: <#failureCallback description#>
    func uploadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback) {
        
        guard let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            if _isDebugAssertConfiguration(){
                print("You have not set upload file within request. Backend request: \(backendRequest.endpoint()) need to implement Upload File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = backendRequest.headers()
        
        guard let tempURL = copyFileTemporaryDirectory(file: file.data!, fileExtension: file.fileExtension!) else{
            if _isDebugAssertConfiguration(){
                print("Can not create temp url path!. Upload file: \(file.name ?? "")")
            }
            failureCallback(nil, 1001)
            return
        }

        getSession(request: backendRequest).upload(tempURL, to: url, method: method, headers: headers)
            .uploadProgress { (progress) in
                
                file.status = .progress
                file.progress = CGFloat(progress.fractionCompleted)
            }
            .responseString { (response) in
                
                file.status = response.result.isSuccess ? .success : .fail
                
                // If success
                if response.result.isSuccess{
                    
                    successCallback(file, (response.response?.statusCode)!)
                    
                } else {
                    if _isDebugAssertConfiguration(){
                        print("error downloading file - \(String(describing: response.error?.localizedDescription))")
                    }
                    failureCallback(response.result.error, response.response?.statusCode ?? -1001)
                }
        }
    }
    
    func uploadMultipart(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        guard let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            if _isDebugAssertConfiguration(){
                print("You have not set upload file within request. Backend request: \(backendRequest.endpoint()) need to implement Upload File protocol")
            }
            failureCallback(nil, 1001)
            return
        }
        
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = backendRequest.headers()
        let encoding = self.getEncodingType(backendRequest: backendRequest)
        let params = self.getParams(backendRequest: backendRequest)
        var mainRequest: URLRequest?
        do{
            let request = try URLRequest(url: url, method: method, headers: headers)
            mainRequest = try encoding.encode(request, with: params)
        }
        catch{
            if _isDebugAssertConfiguration(){
                print("Not able to create url request")
            }
            failureCallback(nil, 1001)
            return
        }
        
        guard let tempURL = copyFileTemporaryDirectory(file: file.data!, fileExtension: file.fileExtension!) else{
            if _isDebugAssertConfiguration(){
                print("Can not create temp url path!. Upload file: \(file.name ?? "")")
            }
            failureCallback(nil, 1001)
            return
        }
        
        guard let dataToUpload = try? Data(contentsOf: tempURL) else{
            if _isDebugAssertConfiguration(){
                print("Can not read file from url path!. Upload file: \(file.name ?? "")")
            }
            failureCallback(nil, 1001)
            return
        }
        
        getSession(request: backendRequest).upload(multipartFormData: { (multipartFormData) in
            
            let mime = "\(file.type ?? "image")/\(file.fileExtension ?? "jpg")"
            multipartFormData.append(dataToUpload, withName: file.type ?? "image", fileName: "\(file.name ?? "image").\(file.fileExtension ?? "jpg")", mimeType: mime)
            
        }, usingThreshold: UInt64.init(), with: mainRequest!) { (result) in
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    file.status = response.result.isSuccess ? .success : .fail
                    successCallback(response.result.value, (response.response?.statusCode)!)
                }
                
                upload.uploadProgress(closure: { (progress) in
                    debugPrint(progress)
                    file.status = .progress
                    file.progress = CGFloat(progress.fractionCompleted)
                })
            case .failure(let error):
                print(error)
                file.status = .fail
                failureCallback(error as NSError, 400)
            }
        }
    }
    
    
    // MARK:- Task manage
    
    func cancel(){
        self.dataTask?.task?.cancel()
    }
    
    func resume(){
        self.dataTask?.task?.resume()
    }
    
    func pause(){
        
        self.dataTask?.task?.suspend()
    }
    
    
    //MARK:- Private funcs
    
    private func getUrl(backendRequest: BackendRequest) -> URL{

        let urlString = SERVER_URL.appending(backendRequest.endpoint())
        return URL(string: urlString)!
    }
    
    private func getMethod(backendRequest: BackendRequest) -> HTTPMethod{
        
        return HTTPMethod(rawValue:backendRequest.method().rawValue.uppercased())!
    }
    
    private func getHeader(backendRequest: BackendRequest) -> HTTPHeaders{
    
        var header = HTTPHeaders()
        
        // Set header for specific server
        _ = COMMON_HEADERS.map{
            header.updateValue($0.value, forKey: $0.key)
        }
        
        // Custom headers
        if let headers = backendRequest.headers(){
            
            for dict in headers {
                
                header.updateValue(dict.value, forKey: dict.key)
            }
        }
        
        return header
    }
    
    
    /// If there is not encoding type set, returns URLEncoding.httpBody
    ///
    /// - Parameter backendRequest: Backend request
    /// - Returns: ParameterEncoding (Alamofire enum)
    private func getEncodingType(backendRequest: BackendRequest) -> ParameterEncoding{
        
        if let paramsEncodingType = (backendRequest as? ManagePostDataProtocol)?.encodingType(){
            
            switch paramsEncodingType{
                
            case .jsonBody:
                return JSONEncoding.prettyPrinted
                
            case .multipartBodyURLEncode:
                return URLEncoding.httpBody
                
            case .urlEncode:
                return URLEncoding.queryString
            }
        }
        return URLEncoding.httpBody
    }
    
    private func getParams(backendRequest: BackendRequest) -> [String : Any]{
        
        guard let params = (backendRequest as? ManagePostDataProtocol)?.getEncodedData()  else {
            return [String:Any]()
        }
        return params
    }
    
    private func encodeSendingData<T: Encodable>(_ sendData: T) -> [String : Any]?{
        
        if let jsonData = try? JSONEncoder().encode(sendData){
            do{
                return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
            }
            catch{
                return nil
            }
        }
        if _isDebugAssertConfiguration(){
            print("Not able to encode data")
        }
        return nil
    }
    
    private func copyFileTemporaryDirectory(file: Data, fileExtension: String ) -> URL?
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
