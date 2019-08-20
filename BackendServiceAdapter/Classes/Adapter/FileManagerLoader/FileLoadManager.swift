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
            print("The \(url.absoluteString) already exists")
            return true
        } else {
            return false
        }
    }
    
    /// Remove question from temp file
    static func removeAllFilesFromTempFolder(){
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
    
    static func getAllFilesFromTempFolder() -> [FileLoad]{
        let docTempDirectory = FileLoadManager.getTempDirectory()
        do{
            let paths = try FileManager.default.contentsOfDirectory(atPath: docTempDirectory.path)
            return paths.compactMap{ path in
                let url = docTempDirectory.appendingPathComponent(path)
                guard let data = try? Data(contentsOf: url), !data.isEmpty, path != ".DS_Store" else{
                    return nil
                }
                return FileLoad(fileId: url.lastPathComponent, path: url)
            }
        }
        catch{
            print("Failed to get files from \(docTempDirectory.absoluteString)", error.localizedDescription)
            
        }
        return []
    }
    
    static func deleteFile(_ fileId: String) throws{
        let path = getTempDirectory().appendingPathComponent(fileId)
        try FileManager.default.removeItem(at: path)
    }
    
    static func writeFile(_ fileId : String, data: Data) throws -> URL{
        let path = getTempDirectory().appendingPathComponent(fileId)
        try data.write(to: path, options: .atomic)
        return path
    }
    
    static func getNewFilePath(_ fileId: String) -> URL{
        return getTempDirectory().appendingPathComponent(fileId)
    }
    
    
    /// Get temp directory
    ///
    /// - Returns: Temp directory URL
    static func getTempDirectory() -> URL{  
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = NSURL(fileURLWithPath: paths.first!, isDirectory: true) as URL
        let docTempDirectory = documentsDirectory.appendingPathComponent("temp")
        
        // If folder don't exsist , create it
        if !checkURL(url: docTempDirectory){
            do {
                try FileManager.default.createDirectory(atPath: docTempDirectory.path, withIntermediateDirectories: false, attributes: nil)
                return docTempDirectory
            } catch {
                fatalError(error.localizedDescription)
            }
        }
            // Return exsisting URL
        else{
            return docTempDirectory
        }
    }
    
}
