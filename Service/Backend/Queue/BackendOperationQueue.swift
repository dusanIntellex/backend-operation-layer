//
//  BackendOperationQueue.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit

class BackendOperationQueue: NSObject {
    
    var queue : OperationQueue?
    
    //MARK:- Initalizer
    
    override init() {
        
        super.init()
        
        self.queue = OperationQueue()
    }
    
    //MARK:- Add operations
    
    func addOperation(operation: BackendOperation){
        
        if !Reachability.isConnectedToNetwork(){
            print("ERROR - No internet connection")
        }
        
        self.queue?.addOperation(operation)
    }
    
    func addOperations(operations: [Operation]){
        
        if !Reachability.isConnectedToNetwork(){
            print("ERROR - No internet connection")
        }
        
        self.queue?.addOperations(operations, waitUntilFinished: false)
    }

}
