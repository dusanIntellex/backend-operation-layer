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

enum RequestType {
    case rest
    case upload
    case uploadMultipart
    case download
}

enum ParametersEncodingType {
    
    case multipartBodyURLEncode
    case urlEncode
    case jsonBody
    case customBody
}

enum HttpMethod : String{
    
    case get = "get"
    case put = "put"
    case post = "post"
    case delete = "delete"
    case insert = "insert"
}

protocol UploadFileProtocol {
    
    var uploadFile: FileLoad{ get set }
}

protocol DownloadFileProtocol {
    
    var fileId: String{ get }
}

protocol SendingDataProtocol {
    
    func sendingModel<T: Encodable>() -> T
}

protocol BackgroundModeProtocol {
    
}

/// Every request have to implement this protocol.
protocol BackendRequest {
    
    func endpoint() -> String
    func method() -> HttpMethod
    
    func headers() -> Dictionary<String, String>?
    
    /// Return what type of request is
    ///
    /// - Returns: Enums: rest,upload,uploadMultipart,download
    func requestType() -> RequestType?
    
    /// Type which define how will parameters be encoded
    ///
    /// - Returns: Enum values of enciding type
    func encodingType() -> ParametersEncodingType?
}




