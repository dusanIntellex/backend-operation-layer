//
//  ExampleModel.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

struct ExampleModel: Codable {

    var id: Int?
    var name: String?
    
}

class ExampleModelObject : NSObject , Codable{
    
    var id: Int?
    
    init(id: Int) {
        super.init()
        
        self.id = id
    }
    
}
