//
//  BackendOperationHandleSuccess.swift
//  BackendServiceAdapter_Example
//
//  Created by Apple on 3/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import BackendServiceAdapter

public extension BackendOperation{
    
    //MARK:- Custom handler response
    @objc func customHandleResponseData(data: Any?, statusCode: NSInteger){
        print("This is swizzle method")
        if self.onSuccess != nil{
            
            if 200 ... 299 ~= statusCode{
                self.onSuccess!(data, statusCode)
            }
            else{
                self.onFailure?(ResponseError.unknownError, statusCode)
            }
        }
        
        self.finish()
    }

    //MARK:- Refresh token
    private func refreshToken(){
        // TODO: You can add this funciton on any status code and recall previous request if everything is ok
    }
    
    //MARK:- Siwzzle method
    
    // Init swizzling
    public static func swizzleHandleSuccess(){
        _ = self.swizzleHandleSuccessOperation
    }
    
    private static let swizzleHandleSuccessOperation : Void = {
        
        let originalSelector = #selector(handleData(data:statusCode:))
        let swizzleSelector = #selector(customHandleResponseData(data:statusCode:))
        
        let originalMethod = class_getInstanceMethod(BackendOperation.self, originalSelector)
        let swizzleMethod = class_getInstanceMethod(BackendOperation.self, swizzleSelector)
        
        if let originalMethod = originalMethod, let swizzledMethod = swizzleMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
}
