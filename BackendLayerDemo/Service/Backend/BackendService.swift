//
//  BackendService.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//



import UIKit

class BackendService: NSObject {
    
    var queue: BackendOperationQueue?
    
    override init() {
        super.init()
        
        self.queue = BackendOperationQueue()
    }
}

extension BackendService{
    
    static func parseDataArray<T: Codable>(type:T.Type, data: [String: Any]) -> ([T]?, PaginationModel?){
        
        var allDataResponse = [T]()
        var pagination: PaginationModel?
        
        if let mainData = data["data"] as? [Any]{
            
            mainData.forEach{
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
        }
        
        if let metaData = data["pagination"] as? [String: Any]{
            
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: metaData, options: .prettyPrinted)
                let jsonDecoder = JSONDecoder()
                pagination = try jsonDecoder.decode(PaginationModel.self, from: jsonData)
            }
            catch let error{
                print(error.localizedDescription)
            }
        }
        
        return(allDataResponse, pagination)
    }
    
    static func parseSingleData<T: Codable>(type: T.Type, data:[String: Any]) -> T?{
        
        if let mainData = data["data"] as? [String: Any]{
            
            do{
                let modelJSON = try JSONSerialization.data(withJSONObject: mainData, options: .prettyPrinted)
                let jsonDecoder = JSONDecoder()
                let model: T = try jsonDecoder.decode(T.self, from: modelJSON)
                return model
            }
            catch let error{
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
