//
//  FileUploadManager.swift
//  IntellexFileUploader
//
//  Created by Vladimir Djokanovic on 3/27/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

public class FileLoadManager: NSObject {

    
    /// Check if file exists on path
    ///
    /// - Parameter url: path for file
    /// - Returns: Bool value
    static func checkURL(url: URL) -> Bool{
        
        if FileManager().fileExists(atPath: url.path) {
            print("The file already exists at path")
            return true
        } else {
            return false
        }
    }
    
    
    /// Get data for index
    ///
    /// - Parameter index: Index of object in download array of datas
    /// - Returns: Encrypted data for index
    static func getFile(fileId: String?) -> NSData?{
        
        if fileId != nil{
            
            let path = createFolder()?.appendingPathComponent(fileId!)
            
            if checkURL(url:path!){
                
                return NSData(contentsOf: path!)
            }
            else{
                
                print("Error: No file on this url path")
                return nil
            }
        }
        return nil
    }
    
    /// Remove question from temp file
    public static func removeAllFilesFromTempFolder(){
        
        let docTempDirectory = FileLoadManager.getTempDirectory()
        
        if FileLoadManager.checkURL(url: docTempDirectory){
            
            do{
                let files = try FileManager.default.contentsOfDirectory(atPath: docTempDirectory.path)
                for filePath in files {
                    print("Try to remove file at path:\(filePath)")
                    try FileManager.default.removeItem(atPath: docTempDirectory.path + "/\(filePath)")
                }
                
            }
            catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    static func writeFile(_ path : URL, data: NSData){
        
        //writing
        do {
            try data.write(to: path, options: .atomic)
        }
        catch {
        
            print("Error for writing file")
        }
    }
    
    
    /// Create folder or if exsist return path
    ///
    /// - Returns: Path of folder
    class func createFolder() -> URL?{
        
        let docTempDirectory = getTempDirectory()
        
        // If folder don't exsist , create it
        if !checkURL(url: docTempDirectory){
            
            do {
                try FileManager.default.createDirectory(atPath: docTempDirectory.path, withIntermediateDirectories: false, attributes: nil)
                return docTempDirectory
            } catch let error as NSError {
                print(error.localizedDescription);
                return nil
            }
        }
            // Return exsisting URL
        else{
            return docTempDirectory
        }
    }
    
    /// Get temp directory
    ///
    /// - Returns: Temp directory URL
    class func getTempDirectory() -> URL{
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = NSURL(fileURLWithPath: paths.first!, isDirectory: true) as URL
        
        return documentsDirectory.appendingPathComponent("IntellexFileUpload")
    }
    
}
