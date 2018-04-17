//
//  BOUploadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class BOUploadExample: BackendOperation {

    
    init(file: FileLoad){
        super.init()
        
        self.request = BRUploadExample(uploadFile: file)
    }
}
