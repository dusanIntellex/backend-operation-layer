//
//  FilesPool.swift
//  IntellexFileUploader
//
//  Created by Dusan Cucurevic on 3/23/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class FilesPool: NSObject {
    
    // MARK:- Properties
    private var pool: [FileLoad]
    static let sharedInstance: FilesPool = {
        let instance = FilesPool()
        return instance
    }()
    
    //MARK:- Init
    
    override init() {
        pool = FileLoadManager.getAllFilesFromTempFolder()
    }
    
    //MARK:- Public
    
    public func addFile(file: FileLoad){
        self.pool.append(file)
    }
 
    public func getFile(fileId: String, _ data: Data? = nil) -> FileLoad{
        let file = pool.first{ $0.fileId == fileId }
        
        //Update file
        if file != nil, data != nil{
            file!.data = data
        }
            
        //Create new file with data or empty data
        else if file == nil{
            do{
                let data = data ?? Data()
                try FileLoadManager.writeFile(fileId, data: data)
                return FileLoad(fileData: data, fileId: fileId)
            }
            catch{
                fatalError(error.localizedDescription)
            }
        }
            
        // Get file
        return file!
    }
    
    public func removeFile(fileId: String){
        pool.removeAll{ $0.fileId == fileId }
        do{
            try FileLoadManager.deleteFile(fileId)
        }
        catch{
            fatalError(error.localizedDescription)
        }
    }
    
    public func clearPool(){
        pool.removeAll()
        FileLoadManager.removeAllFilesFromTempFolder()
    }
}
