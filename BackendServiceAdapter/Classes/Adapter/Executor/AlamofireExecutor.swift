//
//  BackendAlamofireExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import Alamofire

class AlamofireExecutor: NSObject, ExecutorProtocol {

    enum Constant: String {
        case sessionID = "quantox.com.BackendLayerDemo.bgSession"
    }
    
    let timeoutInterval = 30.0
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
            print("""
            /nBackend service request:
                Base url:\n\(backendRequest.baseUrl())
                Route:\n\(backendRequest.route())
                Method:\n\(backendRequest.method())
                Headers:\n\(headers)
                Sending params:\n\(params as AnyObject)
                Parameters encoding type:\n\(encoding)
            """)
        }
        
        dataTask = getSession(request: backendRequest).request(url, method: method, parameters: params, encoding:  encoding, headers:headers).responseJSON { (response:DataResponse<Any>) in
            let statusCode = response.response?.statusCode
            
            if _isDebugAssertConfiguration(){
                print("""
                    Response for request:
                    \(response.request?.url?.absoluteString ?? "unknown")
                    Result:
                    \(response.result)
                    """)
            }
            
            if response.result.isSuccess{
                if let data = response.result.value{
                    successCallback(data, statusCode ?? 0)
                }
                else{
                    successCallback(nil, statusCode ?? 0)
                }
            }
            else{
                failureCallback(ResponseError.serverError,statusCode ?? 0)
            }
        }
        
        dataTask?.task?.resume()
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
        
        let file = FilesPool.sharedInstance.getFile(fileId: fileId)
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
        
        self.dataTask = getSession(request: backendRequest)
            .download(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers, to: destination)
            .downloadProgress(closure: { (progress) in
                file.status = .progress
                file.progress = CGFloat(progress.fractionCompleted)
            })
            .responseString { response in
                file.status = response.result.isSuccess ? .success : .fail
                if _isDebugAssertConfiguration(){
                    let message = response.result.isSuccess ? "File \(fileId) successfully download" : "error downloading file - \(String(describing: response.error?.localizedDescription))"
                    print(message)
                }
                if response.result.isSuccess{
                    successCallback(file, (response.response?.statusCode)!)
                } else {
                    failureCallback(response.result.error ?? BackendRequestError.errorDownloadingFile, response.response?.statusCode ?? -1001)
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
        
        guard backendRequest.taskType() == .upload, let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            fatalError("You have not set upload file id within request. Backend request: \(backendRequest.route()) need to implement Upload File protocol")
        }
        
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = backendRequest.headers()
        
        guard let tempURL = file.path else{
            if _isDebugAssertConfiguration(){
                print("Can not create temp url path!. Upload file: \(file.fileId ?? "")")
            }
            failureCallback(BackendRequestError.errorCreatingTempFile, 1001)
            return
        }

        self.dataTask = getSession(request: backendRequest).upload(tempURL, to: url, method: method, headers: headers)
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
                    failureCallback(response.result.error ?? BackendRequestError.errorDownloadingFile, response.response?.statusCode ?? -1001)
                }
        }
    }
    
    func uploadMultipart(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        guard backendRequest.taskType() == .upload, let file = (backendRequest as? UploadFileProtocol)?.uploadFile else {
            fatalError("You have not set upload file id within request. Backend request: \(backendRequest.route()) need to implement Upload File protocol")
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
            failureCallback(BackendRequestError.errorCreatingURLRequest, 1001)
            return
        }
        
        guard let tempURL = file.path else{
            if _isDebugAssertConfiguration(){
                print("Can not create temp url path!. Upload file: \(file.fileId ?? "")")
            }
            failureCallback(BackendRequestError.errorCreatingTempFile, 1001)
            return
        }
        
        guard let dataToUpload = try? Data(contentsOf: tempURL) else{
            if _isDebugAssertConfiguration(){
                print("Can not read file from url path!. Upload file: \(file.fileId ?? "")")
            }
            failureCallback(BackendRequestError.errorReadingFile, 1001)
            return
        }
        
        getSession(request: backendRequest).upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(dataToUpload, withName: file.type ?? "image", fileName: "\(file.name ?? "image").\(file.fileExtension ?? "jpg")", mimeType: file.mimeType ?? "image/jpg")
            
        }, usingThreshold: UInt64.init(), with: mainRequest!) { (result) in
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if _isDebugAssertConfiguration(){
                        print(response)
                    }
                    file.status = response.result.isSuccess ? .success : .fail
                    successCallback(response.result.value, (response.response?.statusCode)!)
                }
                
                upload.uploadProgress(closure: { (progress) in
                    if _isDebugAssertConfiguration(){
                        print(progress)
                    }
                    file.status = .progress
                    file.progress = CGFloat(progress.fractionCompleted)
                })
            case .failure(let error):
                if _isDebugAssertConfiguration(){
                    print(error.localizedDescription)
                }
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
        let baseUrl = backendRequest.baseUrl()
        let urlString = baseUrl.appending(backendRequest.route())
        guard let endpoint = URL(string: urlString) else{
            fatalError("Endpoint could not be created from base url \"\(baseUrl)\" and route \"\(backendRequest.route())\"")
        }
        return endpoint
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
        if let paramsEncodingType = backendRequest.parametersEncodingType(){
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
        if let params = backendRequest.params() {
            return params
        }
        return [String : Any]()
    }
}
