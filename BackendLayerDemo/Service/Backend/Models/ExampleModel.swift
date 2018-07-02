//
//  ExampleModel.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ExampleModel: BaseModel {

    var id: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}
