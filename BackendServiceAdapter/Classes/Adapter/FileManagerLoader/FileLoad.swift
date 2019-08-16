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
    public var fileId: String?{
        didSet{
            if fileId != nil{
                self.path = FileLoadManager.getTempDirectory().appendingPathComponent(fileId!)
            }
        }
    }
    
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
        FilesPool.sharedInstance.addFile(file: self)
    }
    
    convenience init(fileId: String) {
        self.init()
        self.fileId = fileId
    }
    
    convenience init(fileData: Data, fileId: String){
        self.init()
        self.data = fileData
        self.fileId = fileId
    }
    
    convenience init(path: URL, fileId: String){
        self.init()
        self.path = path
        self.fileId = fileId
    }
    
    convenience init(fileName: String, path: URL, fileExtension: String, fileId: String) {
        self.init()
        self.name = fileName
        self.path = path
        self.fileExtension = fileExtension
        self.fileId = fileId
    }
}
