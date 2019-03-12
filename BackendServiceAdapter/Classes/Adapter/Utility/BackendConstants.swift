//
//  Constants.swift
//  Service
//
//  Created by Vladimir Djokanovic on 8/15/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import Foundation

#if DEBUG
    let SERVER_URL = readPropertyList(enviroment: "development", for: "SERVER_URL") as! String
    let COMMON_HEADERS = readPropertyList(enviroment: "development", for : "COMMON_HEADERS") as! [String: String]
#else
    let SERVER_URL = readPropertyList(enviroment: "production", for: "SERVER_URL") as! String
    let COMMON_HEADERS = readPropertyList(enviroment: "debug", for : "COMMON_HEADERS") as! [String: String]
#endif

private func readPropertyList(enviroment: String, for key: String) -> Any {
    if let path = Bundle.main.path(forResource: "BackendServiceAdapterConfig", ofType: "plist") {
        let nsDictionary = NSDictionary(contentsOfFile: path)
        if let enviromentDict = nsDictionary?.value(forKey: enviroment) as? [String: Any]{
            if let value = enviromentDict[key]{
                return value
            }
            else{
                fatalError("There is no key:\(key) in \"BackendServiceAdapterConfig.plist\"")
            }
        }
        else{
            fatalError("Please add enviroment to \"BackendServiceAdapterConfig.plist\"")
        }
    }
    else{
        fatalError("Please add \"BackendServiceAdapterConfig.plist\" file to BackendLayerAdapter folder")
    }
}
