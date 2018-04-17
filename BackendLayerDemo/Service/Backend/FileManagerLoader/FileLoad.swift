//
//  FileLoad.swift
//  IntellexFileUploader
//
//  Created by Dusan Cucurevic on 3/23/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Alamofire
import UIKit


@objc
public enum FileStatus: Int, CustomStringConvertible {
    case pending, pause, progress, success, fail, cancel
    
    public var description: String{
        
        switch self {
            
        case .pending: return "Pending"
        case .pause: return "Pause"
        case .progress: return "Progress"
        case .success: return "Success"
        case .fail: return "Fail"
        case .cancel: return "Cancel"
        }
    }
}

public class FileLoad: NSObject {
    
    // MARK:- Properties
    
    @objc public dynamic var status: FileStatus = .pending
    @objc public dynamic var progress: CGFloat = 0.0
    public var fileId: String?
    
    public var path: URL?
    @objc public dynamic var uploadedPath: String?
    public var type: String?
    public var mimeType: String?
    public var fileExtension: String?
    public var metaData: NSDictionary?
    public var size: NSInteger?
    public var name: String?
    public var data: Data?
//    public var process: UploadRequest?
    
    // MARK:- Constructor
    public override init() {
        super.init()
        
        FilesPool.sharedInstance.pool?.append(self)
    }
    
    init(fileId: String) {
        super.init()
        
        self.fileId = fileId
        FilesPool.sharedInstance.pool?.append(self)
    }
    
    /// Return file with id from pool array. If not exsist create new file
    ///
    /// - Parameter fileId: unique file id
    /// - Returns: FileUpload object
    public static func getFile(fileId: String, data: NSData?) -> FileLoad{
        
        if let file = FilesPool.sharedInstance.pool?.first(where: {$0.fileId == fileId }){
            
            if data != nil{
                FileLoadManager.writeFile(file.path!, data: data!)
            }
            
            return file
        }
        else{
            
            let file = FileLoad(fileId: fileId)
            file.path = FileLoadManager.createFolder()?.appendingPathComponent(fileId)
            
            if data != nil{
                FileLoadManager.writeFile(file.path!, data: data!)
            }
            
            return file
        }
    }
}
