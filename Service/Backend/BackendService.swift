//
//  BackendService.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class BackendService: NSObject {
    
    var queue: BackendOperationQueue?
    
    override init() {
        super.init()
        
        self.queue = BackendOperationQueue()
    }
    
    

}
