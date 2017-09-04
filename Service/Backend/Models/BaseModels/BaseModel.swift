//
//  BaseModel.swift
//  AuthorizationApp
//
//  Created by Vladimir Djokanovic on 8/16/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseModel: NSObject, Mappable {

    override init() {
        super.init()
    }

    required init(value: Any?) {
        super.init()
        
        if self is FirBModel{
            self.snapshoting(snapshot: value as Any)
        }
        else{
            self.mapping(map: value as! Map)
        }
    }
    
    required init(map: Map) {
        
    }
    
    func mapping(map: Map) {
    }

   
    func snapshoting(snapshot: Any) {
    }
}


