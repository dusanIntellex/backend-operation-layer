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
    required convenience init(fileId: String, data: Data, name: String, type: String, fileExtension: String){
        self.init(fileData: data, fileId: fileId)
        self.name = name
        self.type = type
        self.fileExtension = fileExtension
        self.mimeType = "\(type)/\(fileExtension)"
    }
}

public protocol UploadFileProtocol : class {
    var uploadFile: UploadFile?{ get set }
}

public protocol DownloadFileProtocol {
    var fileId: String{ get set }
}

public protocol BackgroundModeProtocol { }

/// Every request have to implement this protocol.
public protocol BackendRequest {
    
    func baseUrl() -> String
    func route() -> String
    func method() -> HttpMethod
    func headers() -> Dictionary<String, String>?
    
    func params() -> [String: Any]?
    
    /// Type which define how will parameters be encoded
    ///
    /// - Returns: Enum values of enciding type
    func parametersEncodingType() -> ParametersEncodingType?
    
    /// Return what type of request is
    ///
    /// - Returns: Enums: rest,upload,uploadMultipart,download
    func taskType() -> TaskType
}

extension BackendRequest{
    
    /// This function set base url for default value read from Plist config file. To override base url, override this function in specific backend request file
    ///
    /// - Returns: Base server url
    public func baseUrl() -> String{
        return SERVER_URL
    }
}



