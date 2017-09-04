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
    
    var pool: [FileLoad]?
    
    static let sharedInstance: FilesPool = {
        
        let instance = FilesPool(array: [])
        return instance
    }()
    
    
    init(array: [FileLoad]) {
        
        pool = array
    }

    
    // TODO: Cache settings
}
