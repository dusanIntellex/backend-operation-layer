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
    
    // MARK:- Properties
    var fileId: String?
    public weak var file: FileLoad?
    var handler : FileObserverHandler?
    var keyPaths = [#keyPath(FileLoad.progress), #keyPath(FileLoad.status)]
    
    
    // MARK:- Init
    public override init() {
        super.init()    
    }
    
    public init(fileId: String) {
        super.init()
        self.file = FilesPool.sharedInstance.getFile(fileId: fileId)
    }
    
    public func subscribeForFileUpload(fileHandler: FileObserverHandler?){
        for path in keyPaths{
            file?.addObserver(self, forKeyPath: path, options: .new, context: nil)
        }
        handler = fileHandler
    }
    
    deinit {
        unsubscribeAll()
    }
    
    public func unsubscribeAll(){
        for path in keyPaths{   
            file?.removeObserver(self, forKeyPath: path)
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPaths.contains(keyPath!){
            if let file = object as? FileLoad{
                handler!(file)
            }
        }
    }
}

