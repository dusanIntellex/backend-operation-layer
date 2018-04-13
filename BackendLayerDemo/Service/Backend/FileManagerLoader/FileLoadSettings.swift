//
//  FileLoadSettings.swift
//  IntellexFileUploader
//
//  Created by Dusan Cucurevic on 3/23/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

public class FileLoadSettings: NSObject {
    
    // MARK:- Properties
    var baseUrl: String?
    var cacheFiles: Bool?
    var cacheTimeMaximum: NSInteger?
    var cacheFileMaximum: NSInteger?
    
    // MARK:- Constructor
    
    static let sharedInstance: FileLoadSettings = {
        
        let instance = FileLoadSettings()
        
        return instance
    }()
    
    /// Config Upload with base url without cache files
    ///
    /// - Parameter baseUrl: Base url for upload files
    public static func configUploader(baseUrl: String){
        
        FileLoadSettings.sharedInstance.baseUrl = baseUrl
    }
    
    // TODO: Add cachiong settings
    public static func configUploader(baseUrl: String, cacheMaximumFilesInterval: NSInteger){
        
    }

    public static func configUploader(baseUrl: String, cacheMaximumFilesNumber: NSInteger){
        
    }
    
    public static func configUploader(baseUrl: String, cacheMaximumFilesSize: NSInteger){
        
    }
    
}
