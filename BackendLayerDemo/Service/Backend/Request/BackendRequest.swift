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
}

enum HttpMethod : String{
    
    case get = "get"
    case put = "put"
    case post = "post"
    case delete = "delete"
    case insert = "insert"
}

protocol UploadFileProtocol : class {
    
    var uploadFile: FileLoad?{ get set }
}

protocol DownloadFileProtocol {
    
    var fileId: String{ get }
}

public protocol SendingDataProtocol {
    
    associatedtype GenericEncodableType : Encodable
    var sendingModel : GenericEncodableType? { get set }
}

protocol SendingDataManageProtocol {
    
    func setSendingData(data: Encodable)
    func getEncodedData() -> [String: Any]?
    
    /// Type which define how will parameters be encoded
    ///
    /// - Returns: Enum values of enciding type
    func encodingType() -> ParametersEncodingType?
}

extension SendingDataProtocol{
    
    func encode() -> [String: Any]? {
        
        if let jsonData = try? JSONEncoder().encode(sendingModel!){
            do{
                return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
            }
            catch{
                return nil
            }
        }
        
        return [String: Any]()
    }
}

typealias SendingProtocols = SendingDataProtocol & SendingDataManageProtocol

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
}



