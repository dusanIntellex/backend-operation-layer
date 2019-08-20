//
//  EncodingHelper.swift
//  BidBeds
//
//  Created by Apple on 6/25/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

class EncodingHelper {
    static func encode<T:Codable>(model: T) -> [String: Any]? {
        if let jsonData = try? JSONEncoder().encode(model){
            do{
                return try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as? [String : Any]
            }
            catch{
                return nil
            }
        }
        return [String: Any]()
    }
}
