//
//  BackendRequest.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/14/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Foundation

// Const
let BRFileField = "file"
let BRFileIdConst = "fileId"
let BRDataConst = "data"
let BRFileNameConst = "name"
let BRFileExtensionConst = "extension"
let BRFilePathConst = "path"

public enum TaskType {
    case rest
    case upload
    case uploadMultipart
    case download
}

public enum ParametersEncodingType {
    case multipartBodyURLEncode
    case urlEncode
    case jsonBody
}

public enum HttpMethod : String{
    case get = "get"
    case put = "put"
    case post = "post"
    case delete = "delete"
    case insert = "insert"
}

public class UploadFile : FileLoad{
    public convenience init(filePath: URL, fileId: String, dataName: String, dataFilename: String, fileExtension: String){
        self.init(path: filePath, fileId: fileId)
        self.dataName = dataName
        self.dataFilename = dataFilename
        self.fileExtension = fileExtension
        self.mimeType = "\(dataName)/\(fileExtension)"
    }
}

public protocol UploadFileProtocol : class {
    var uploadFile: UploadFile! { get set }
    
    /// This init is required for upload protocol
    ///
    /// - Parameters:
    ///   - fileId: Name of upload file
    ///   - filePath: Path where file is read from
    ///   - name: Key for sending data
    ///   - type: Value for 
    ///   - fileExtension: <#fileExtension description#>
//    Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
//    Content-Type: #{mimeType} (HTTP Header)
    
    
    /// Required init for upload file
    ///
    /// - Parameters:
    ///   - fileId: Name of the file
    ///   - filePath: URL where file is stored
    ///   - dataName: <#dataName description#>
    ///   - dataFilename: <#dataFilename description#>
    ///   - fileExtension: <#fileExtension description#>
    init(fileId: String, filePath: URL, dataName: String, dataFilename: String, fileExtension: String)
}

public protocol DownloadFileProtocol {
    var fileId: String{ get set }
    init(fileId: String)
}

public protocol BackgroundModeProtocol { }

public enum RequestExecutorType{
    case alamofire
    case urlSession
    case firebase
}

/// Every request have to implement this protocol.
public protocol BackendRequest{
    
    func executor() -> RequestExecutorType
    func baseUrl() -> String
    func route() -> String
    func method() -> HttpMethod
    func headers() -> Dictionary<String, String>?
    
    func params() -> [String: Any]?
    
    /// Type which define how will parameters be encoded
    ///
    /// - Returns: Enums: multipartBodyURLEncode, urlEncode, jsonBody
    func parametersEncodingType() -> ParametersEncodingType?
    
    /// Return what type of request is
    ///
    /// - Returns: Enums: rest,upload,uploadMultipart,download
    func taskType() -> TaskType
}

extension BackendRequest{
    
    /// This is default executor. If you want to override this, in Backlend request implementation, override this function in specific backend request
    ///
    /// - Returns: enums : alamofire, urlSession, firebase
    public func executor() -> RequestExecutorType{
        return .alamofire
    }
    
    /// This function set base url for default value read from Plist config file. To override base url, override this function in specific backend request file
    ///
    /// - Returns: Base server url
    public func baseUrl() -> String{
        return SERVER_URL
    }
}

extension BackendRequest {
    func printRequest() {
        var header = [String : Any]()
        _ = COMMON_HEADERS.map{
            header.updateValue($0.value, forKey: $0.key)
        }
        if let headers = self.headers(){
            for dict in headers {
                header.updateValue(dict.value, forKey: dict.key)
            }
        }
        if _isDebugAssertConfiguration(){
            print("""
            \n***Backend service request***\n
            Base url:\n    \(self.baseUrl())
            Route:\n    \(self.route())
            Method:\n    \(self.method())
            Headers:\n\(header as AnyObject)
            Sending params:\n\(self.params() as AnyObject)
            Parameters encoding type:\n    \(String(describing: self.parametersEncodingType())) \n
            """)
        }
    }
}



