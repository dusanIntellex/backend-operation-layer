//
//  ModelParser.swift
//  Brave Heart Minute
//
//  Created by Vladimir Djokanovic on 8/23/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ModelParser: NSObject {

    
    static func parseArray<T: BaseModel>(data : Any, type: T.Type) -> [T]{
        
        var array = [T]()
        
        if let data = data as? DataSnapshot{
            
            if let allDicts = data.value as? NSDictionary{
                
                for key in allDicts.allKeys {
                    
                    let obj = T(value: allDicts.value(forKey: key as! String))
                    (obj as! FirBModel).key = key as? String
                    array.append(obj)
                }
            }
        }
        else if  let categories = data as? [Any]{
            
            for cat in categories{
                
                let category = T(value: cat)
                array.append(category)
            }
        }
        
        return array
    }
    
    static func parseObject<T:FirBModel>(data: Any, type: T.Type) -> T {
        
        return T(value: data)
    }
}
