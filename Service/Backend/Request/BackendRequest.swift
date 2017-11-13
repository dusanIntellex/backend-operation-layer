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


/// Every request have to implement this protocol.
protocol BackendRequest {
    
    func endpoint() -> String
    func method() -> HttpMethod
    
    /// For upload and download use const from top of the class
    ///
    /// - Returns: Dictionary
    func paramteres() -> Dictionary<String, Any>?
    func headers() -> Dictionary<String, String>?
    
    func requestType() -> RequestType?
    
    /// Value is used to track changes on real datebase in Firebse. Default is nil
    ///
    /// - Returns: Bool value for tracking changes of observer model in Firebase
    func firebaseObserver() -> Bool?
    
    
    /// Type which define how will parameters be encoded
    ///
    /// - Returns: Enum values of enciding type
    func encodingType() -> ParametersEncodingType?
    
    
    /// If encoding Type is custom body, executor will use custom body for created request
    ///
    /// - Returns: Data
    func createBody() -> Data?
}
