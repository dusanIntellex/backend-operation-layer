//
//  DecodingHelper.swift
//  BidBeds
//
//  Created by Apple on 6/26/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation


class DecodingHelper {
    
    static func decode<T:Codable>(jsonDict: Any) -> T?{
        
        let data = try? JSONSerialization.data(withJSONObject: jsonDict as Any, options: .prettyPrinted)
        let jsonDecoder = JSONDecoder()
        guard let dataDict = data, let object = try? jsonDecoder.decode(T.self, from: dataDict) else{
            return nil
        }
        return object
    }
}
