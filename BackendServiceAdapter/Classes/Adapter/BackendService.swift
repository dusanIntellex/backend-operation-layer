//
//  BackendService.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//



import UIKit

open class BackendService: NSObject {
    
    open var queue: BackendOperationQueue?
    
    public override init() {
        super.init()
        
        self.queue = BackendOperationQueue()
    }
}

extension BackendService{
    
    public static func parseDataArray<T: Codable>(type:T.Type, data: [Any]) -> [T]?{
        
        var allDataResponse = [T]()
        
        data.forEach{
            do{
                let responseModel = try JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted)
                let jsonDecoder = JSONDecoder()
                let model: T = try jsonDecoder.decode(T.self, from: responseModel)
                allDataResponse.append(model)
            }
            catch let error{
                print(error.localizedDescription)
            }
        }
        
        return allDataResponse
    }
    
    public static func parseSingleData<T: Codable>(type: T.Type, data:[String: Any]) -> T?{
        
        do{
            let modelJSON = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let jsonDecoder = JSONDecoder()
            let model: T = try jsonDecoder.decode(T.self, from: modelJSON)
            return model
        }
        catch let error{
            print(error.localizedDescription)
            return nil
        }
    }
}
