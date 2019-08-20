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
    lazy var pool : [FileLoad] = {
        return FileLoadManager.getAllFilesFromTempFolder()
    }()
    static let sharedInstance: FilesPool = {
        return FilesPool()
    }()
    
    //MARK:- Public
    
    public func addFile(file: FileLoad){
        if (self.pool.filter{ $0.fileId == file.fileId }.isEmpty){
            self.pool.append(file)
        }
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
                if data != nil{
                    let path = try FileLoadManager.writeFile(fileId, data: data!)
                    return FileLoad(path: path, fileId: fileId, data: data)
                }
                else{
                    let newFile = FileLoad(fileId: fileId)
                    newFile.path = FileLoadManager.getNewFilePath(fileId)
                    return newFile
                }
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
