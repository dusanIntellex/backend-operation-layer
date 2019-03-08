//
//  FileUploadHelper.swift
//  Virtuzone
//
//  Created by Apple on 2/20/18.
//  Copyright © 2018 Quantox. All rights reserved.
//

import UIKit

class FileUploadHelper: NSObject {
    
    enum FileUploadError: Error{
        case unsuportedExtension(String)
    }
    
    static func  createUploadFile(url:URL) throws -> FileLoad?{
        
        var fileExt = ""
        var fileName = ""
        let parts = url.lastPathComponent.components(separatedBy: ".")
        if parts.count > 1{
            fileName = parts[0]
            fileExt = parts[1]
        }
        
        guard fileExt == "pdf" || fileExt == "doc" || fileExt == "docx" else{
            
            let message = NSLocalizedString("\(fileExt) is unsuppored extension", comment: "")
            throw FileUploadError.unsuportedExtension(message)
        }
        
        let file = FileLoad(fileName: fileName, path: url as URL, fileExtension: fileExt, fileId: url.lastPathComponent )
        file.data = try? Data(contentsOf: url)
        file.type = "file"
        
        return file
    }
}
