//
//  BackendAlamofireExecutor.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import Alamofire

class BackendAlamofireExecutor: NSObject {

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
        
        print("Service request:\nEndpoint:\(backendRequest.endpoint())\nHeaders:\(headers))\nParams:\(String(describing: backendRequest.paramteres()))")
        
        dataTask = Alamofire.request(url, method: method, parameters: backendRequest.paramteres(), encoding: JSONEncoding.default, headers:headers).responseJSON { (response:DataResponse<Any>) in
            
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
        
        guard let fileId = backendRequest.paramteres()?[BRFileIdConst] else {
            failureCallback(nil, 1001)
            return
        }
        
        // File located on disk
        let file = FileLoad.getFile(fileId: fileId as! String, data: NSData())
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = self.getHeader(backendRequest: backendRequest)
        let params = backendRequest.paramteres()
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        self.dataTask = Alamofire.download(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers, to: destination).downloadProgress(closure: { (progress) in
            
            //progress closure
                file.status = .progress
                file.progress = CGFloat(progress.fractionCompleted)
                
            }).responseString { response in
                debugPrint(response)
                
                file.status = response.result.isSuccess ? .success : .fail
                
                // If success
                if response.result.isSuccess{
                    
                    if let responseDict = response.result.value?.data(using: String.Encoding.utf8) {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: responseDict, options: []) as? [String : Any]
                            
                            successCallback(json, (response.response?.statusCode)!)
                            
                        } catch {
                            print("error getting image path \(error.localizedDescription)")
                            failureCallback(error, (response.response?.statusCode)!)
                        }
                    }
                } else {
                    
                    print("error uploading image - \(String(describing: response.error?.localizedDescription))")
                    failureCallback(response.result.error, (response.response?.statusCode)!)
                }
        }
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
        
        let file = FileLoad.getFile(fileId: fileId as! String, data: nil)
        let url = self.getUrl(backendRequest: backendRequest)
        let method = self.getMethod(backendRequest: backendRequest)
        let headers = self.getHeader(backendRequest: backendRequest)
        
        self.dataTask = Alamofire.upload(file.path!, to: url, method: method, headers: headers)
            
            .uploadProgress { progress in // main queue by default
                
                file.status = .progress
                file.progress = CGFloat(progress.fractionCompleted)
            }
            .downloadProgress { progress in // main queue by default
                
                file.status = .progress
                file.progress = CGFloat(progress.fractionCompleted)
            }
            .responseString { response in
                debugPrint(response)
                
                file.status = response.result.isSuccess ? .success : .fail
                
                // If success
                if response.result.isSuccess{
                    
                    if let responseDict = response.result.value?.data(using: String.Encoding.utf8) {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: responseDict, options: []) as? [String : Any]
                            
                            successCallback(json, (response.response?.statusCode)!)
                            
                        } catch {
                            print("error getting image path \(error.localizedDescription)")
                            failureCallback(error, (response.response?.statusCode)!)
                        }
                    }
                } else {
                    
                    print("error uploading image - \(String(describing: response.error?.localizedDescription))")
                    failureCallback(response.result.error, (response.response?.statusCode)!)
                }
        }
    }
    
    /// Upload with multipart system.
    ///
    /// - Parameters:
    ///   - fileId: Unique file id
    ///   - data: File data
    ///   - name: Name of file
    ///   - fileExtension: Extension of file
    ///   - successCallback: Return data and status code
    ///   - failureCallback: Return error and stts code
    func uploadMultipartFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        guard let fileId = backendRequest.paramteres()?[BRFileIdConst], let data = backendRequest.paramteres()?[BRDataConst], let name = backendRequest.paramteres()?[BRFileNameConst], let fileExtension = backendRequest.paramteres()?[BRFileExtensionConst] else { return }
        
        let file = FileLoad.getFile(fileId: fileId as! String, data: data as? NSData)
        let url = self.getUrl(backendRequest: backendRequest)
        
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in multipartFormData.append(file.path!, withName: name as! String, fileName: fileId as! String, mimeType: fileExtension as! String) },
            to: url,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    self.dataTask = upload
                    
                    upload.responseJSON { response in
                        debugPrint(response)
                        file.status = response.result.isSuccess ? .success : .fail
                        
                        successCallback(response, (response.response?.statusCode)!)
                    }
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Progress: \(progress)")
                        file.status = .progress
                        file.progress = CGFloat(progress.fractionCompleted)
                    })
                    
                case .failure(let encodingError):
                    
                    print(encodingError)
                    file.status = .fail
                    failureCallback(encodingError, 400)
                }
        })
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
        
        // Common headers
        header.updateValue("ios", forKey: "Client-Type")
        header.updateValue("application/json", forKey: "Accept")
        header.updateValue("application/json", forKey: "Content-Type")
        
        // Custom headers
        if let headers = backendRequest.headers(){
            
            for dict in headers {
                
                header.updateValue(dict.value, forKey: dict.key)
            }
        }
        
        return header
    }
    
}
