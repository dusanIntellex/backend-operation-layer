//
//  BaseModel.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class BaseModel: NSObject, Codable{

    func encode(to encoder: Encoder) throws {
        assertionFailure("Implement encode function for class \(String(describing: self))")
    }
    
}
