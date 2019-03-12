//
//  RxBackendOperationExtension.swift
//  BackendServiceAdapter
//
//  Created by Apple on 3/8/19.
//

import Foundation
import RxSwift

enum ResponseParseError {
    case invalidJSONFormat
    case decodeJSONError
}

extension ResponseParseError : LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .invalidJSONFormat:
            return NSLocalizedString("Invalid JSON format", comment: "")
        default:
            return nil
        }
    }
}

extension Reactive where Base : BackendService{
    
    public func response(request: BackendRequest, model: Encodable? = nil) -> Observable<Any>{
        
        return Observable.create{ observer in
            
            let operation = BackendOperation(model: model, request: request)
            
            operation.onSuccess = { data, status in
                observer.onNext(data!)
                observer.on(.completed)
            }
            
            operation.onFailure = { error , status in
                observer.on(.error(error))
            }
            
            self.base.queue?.addOperation(operation: operation)
            
            return Disposables.create()
        }
    }
    
    public func parse<T: Codable>(request :BackendRequest, type: T.Type, model: Encodable? = nil) -> Observable<T>{
        return response(request: request, model: model).map { value -> T in
            if let dict = value as? [String : Any]{
                if let decodableData = BackendService.parseSingleData(type: type, data: dict){
                    return decodableData
                }
                else{
                    throw ResponseParseError.decodeJSONError
                }
            }
            else{
                throw ResponseParseError.invalidJSONFormat
            }
        }
    }
    
    public func parseArray<T: Codable>(request :BackendRequest, type: T , model: Encodable? = nil) -> Observable<[T]>{
        return response(request: request, model: model).map { value -> [T] in
            if let dict = value as? [Any]{
                if let decodableData = BackendService.parseDataArray(type: T.self, data: dict){
                    return decodableData
                }
                else{
                    throw ResponseParseError.decodeJSONError
                }
            }
            else{
                throw ResponseParseError.invalidJSONFormat
            }
        }
    }
}

