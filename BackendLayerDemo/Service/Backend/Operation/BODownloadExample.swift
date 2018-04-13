//
//  BODownloadExample.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class BODownloadExample: BackendOperation {

    override init() {
        super.init()
        
        self.request = BRDownloadExample()
    }
}
