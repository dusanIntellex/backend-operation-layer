//
//  RxBackendOperationExtension.swift
//  BackendServiceAdapter
//
//  Created by Apple on 3/8/19.
//

import Foundation
import RxSwift

extension Reactive where Base : BackendOperation{
    
    func response(request: BackendRequest, model: Encodable? = nil) -> Observable<Data>{
        
        return Observable.create{ observer in
            
            let operation = BackendOperation(model: model, request: request)
            
            operation.onSuccess = { data, status in
                
            }
            
            operation.onFailure = { error , status in
                observer.onError(error)
            }
            
            return Disposables.create(with: operation.cancel)
        }
    }
}
