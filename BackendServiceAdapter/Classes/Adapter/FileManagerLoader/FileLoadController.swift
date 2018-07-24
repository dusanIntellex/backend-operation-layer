//
//  FileLoadController.swift
//  IntellexFileUploader
//
//  Created by Dusan Cucurevic on 3/23/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

public typealias FileObserverHandler = (_ file: FileLoad) -> Void

public class FileLoadController: NSObject {
    
    var fileId: String?
    public var file: FileLoad?
    var handler : FileObserverHandler?
    var keyPaths = [#keyPath(FileLoad.progress), #keyPath(FileLoad.status)]
    lazy var addedKeyPaths : [Any] = {
        return Array<Any>()
    }()
    
    
    convenience public init(operation: BackendOperation){
        
        guard let fileId = (operation.request as? DownloadFileProtocol)?.fileId else{
            fatalError("Adopt DownloadFileProtocol and set fileId")
        }
        
        self.init(fileId: fileId)
    }
    
    public init(fileId: String) {
        
        super.init()
        
        self.file = FileLoad.getFile(fileId: fileId, data: nil)
    }
    
    public func  getFileData() -> NSData?{
    
        return FileLoadManager.getFile(fileId: file?.fileId)
    }
    
    public func subscribeForFileUpload(fileHandler: FileObserverHandler?){
        
        for path in keyPaths{
        
            file?.addObserver(self, forKeyPath: path, options: .new, context: nil)
            addedKeyPaths.append(path)
        }
        
        handler = fileHandler
    }
    
    deinit {
        
        for path in addedKeyPaths{
            file?.removeObserver(self, forKeyPath: path as! String)
        }
    }
    
    public func unsubscribe(from operation: BackendOperation, removeFromPool: Bool){
        
        if let fileId = (operation.request as? DownloadFileProtocol)?.fileId{
            unsubscribe(fileId: fileId, removeFromPool: removeFromPool)
        }
        else{
            print("Not able to get file id from request")
        }
    }
    
    public func unsubscribe(fileId: String, removeFromPool: Bool){
        
        for path in addedKeyPaths{
            
            file?.removeObserver(self, forKeyPath: path as! String)
            
            if removeFromPool{
                FilesPool.sharedInstance.pool?.enumerated().forEach{
                    if $0.element.fileId == file?.fileId{
                        if $0.offset < (FilesPool.sharedInstance.pool?.count)!{
                            FilesPool.sharedInstance.pool?.remove(at: $0.offset)
                        }
                        else{
                            assertionFailure("Something wrong with this pool. Check this!!!")
                        }
                    }
                }
            }
        }
        
        addedKeyPaths.removeAll()
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPaths.contains(keyPath!){
            
            if let file = object as? FileLoad{
            
                handler!(file)
            }
        }
    }
}

