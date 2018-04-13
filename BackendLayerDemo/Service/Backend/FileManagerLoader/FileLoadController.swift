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
    var addedKeyPaths = Array<Any>()
    
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
    
    public func unsubscribe(fileId: String){
        
        for path in addedKeyPaths{
            
            file?.removeObserver(self, forKeyPath: path as! String)
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

