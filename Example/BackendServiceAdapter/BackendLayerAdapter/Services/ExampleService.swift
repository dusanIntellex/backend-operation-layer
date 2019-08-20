//
//  ExampleService.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter
import RxSwift

class ExampleService: BackendService {
    
    private var fileController: FileLoadController?
    
    //MARK:- Normal request
    func getRestExample(response: @escaping (_ dataResponse: Any?) -> Void){
        
        let operation = BackendOperation(BRGetSampleRequest())
        
        operation.onSuccess = {(data, status) in
            
            response(data)
        }
        
        operation.onFailure = {(error, status) in
            
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
            
            response(nil)
        }
        
        self.queue?.addOperation(operation: operation)
    }
    
    func postRestExample(exampleModel: ExampleModel, response: @escaping (_ response: Any?) -> Void){
        
        let operation = BackendOperation(BRPostSampleRequest(model: exampleModel))
        
        operation.onSuccess = {(data, status) in
            
            response(data)
        }
        
        operation.onFailure = {(error, status) in
            
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
            
            response(nil)
        }
        
        self.queue?.addOperation(operation: operation)
    }
    
    func downloadFile(response: @escaping (_ responseFile: FileLoad?) -> Void, progress: @escaping (_ file : FileLoad) -> Void){

        let request = BRDownloadExample(fileId: "example file")
        let operation = BackendOperation(request)
        
        // Track progress
        fileController = FileLoadController.init(fileId: request.fileId)
        fileController?.subscribeForFileUpload { (file) in
            progress(file)
        }
        
        operation.onSuccess = { (file, status) in
            response(file as? FileLoad)
        }
        
        operation.onFailure = { (error, status) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                UIApplication.topViewController().present(alert, animated: true, completion: nil)
            }
            response(nil)
        }

        self.queue?.addOperation(operation: operation)
    }
    
    func uploadFile(uploadFile fileId: String, path: URL, name: String, type: String, fileExtension: String, response: @escaping SuccessCallback,  progress: @escaping (_ file : FileLoad) -> Void){

        let operation = BackendOperation(BRUploadExample(fileId: fileId, filePath: path, name: name, type: type, fileExtension: fileExtension))
        
        operation.onSuccess = {(json, status) in
            response(true)
        }
        
        operation.onFailure = {(error, status) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                UIApplication.topViewController().present(alert, animated: true, completion: nil)
            }
            response(false)
        }
        
        // Track progress
        self.fileController = FileLoadController.init(fileId: fileId)
        self.fileController?.subscribeForFileUpload { (file) in
            progress(file)
        }
        
        self.queue?.addOperation(operation: operation)
    }
    
    //MARK:- Rx Requests
    func getRestExample() -> Observable<ExampleGetModel>{
        return self.rx.parse(request: BRGetSampleRequest(), type: ExampleGetModel.self)
    }
}
