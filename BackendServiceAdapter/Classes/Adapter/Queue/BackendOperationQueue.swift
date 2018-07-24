//
//  BackendOperationQueue.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

public class BackendOperationQueue: NSObject {
    
    var queue : OperationQueue?
    
    //MARK:- Initalizer
    
    override init() {
        
        super.init()
        
        self.queue = OperationQueue()
    }
    
    //MARK:- Add operations
    
    public func addOperation(operation: BackendOperation){
        
        self.queue?.addOperation(operation)
    }
    
    public func addOperations(operations: [Operation]){
        
        self.queue?.addOperations(operations, waitUntilFinished: false)
    }

}
