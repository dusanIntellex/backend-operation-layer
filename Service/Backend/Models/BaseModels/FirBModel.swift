//
//  FirBModel.swift
//  Brave Heart Minute
//
//  Created by Vladimir Djokanovic on 8/23/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FirBModel: BaseModel {
    
    var key: String?
    
    override func snapshoting(snapshot: Any) {
        
        setBasicData(snapshot: snapshot as! NSDictionary)
    }
    
    func setBasicData(snapshot: NSDictionary){
        
        let properties = propertyNames()
        
        for key in snapshot.allKeys {
            
            if properties.contains(key as! String){
                
                if let paramObj = value(forKey: key as! String) as? FirBModel{
                    
                    let obj = type(of: paramObj).init(value:snapshot.value(forKey: key as! String) as Any)
                    self.setValue(obj, forKey: key as! String)
                }
                else{
                    
                    self.setValue(snapshot.value(forKey: key as! String), forKey: key as! String)
                }
            }
        }
    }
}

extension NSObject
{
    
    func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }
    
}
