//
//  ExampleService.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import BackendServiceAdapter

class ExampleService: BackendService {
    
    private var fileController: FileLoadController?
    
    func getRestExample(response: @escaping (_ dataResponse: Any?) -> Void){
        
        let operation = BackendOperation(model: nil, request: BackendReqestRegister.Example.rest)
        
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
        
        let operation = BackendOperation(model: exampleModel, request: BackendReqestRegister.Example.post)
        
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
    
    func postRestExample(exampleModelObject: ExampleModelObject, response: @escaping (_ response: Any?) -> Void){
        
        let operation = BackendOperation(model: exampleModelObject, request: BackendReqestRegister.Example.post)
        
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

        let operation = BackendOperation(model: nil, request: BackendReqestRegister.Example.download)
        
        operation.onSuccess = { [weak self] (file, status) in
            self?.fileController?.unsubscribe(fileId: BackendReqestRegister.Example.download.fileId)
            response(file as? FileLoad)
        }
        
        operation.onFailure = { [weak self] (error, status) in
            
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)

            self?.fileController?.unsubscribe(fileId: BackendReqestRegister.Example.download.fileId)
            response(nil)
        }
        
        self.queue?.addOperation(operation: operation)
        
        // Track progress
        fileController = FileLoadController.init(fileId: BackendReqestRegister.Example.download.fileId)
        fileController?.subscribeForFileUpload { (file) in
            progress(file)
        }
    }
    
    func uploadFile(uploadFile: FileLoad, response: @escaping SuccessCallback,  progress: @escaping (_ file : FileLoad) -> Void){
        
        /*
        GoogleClient.authorize { [weak self] (success) in

            if success{

                // Track progress
                self?.fileController = FileLoadController.init(fileId: uploadFile.fileId ?? "")
                self?.fileController?.subscribeForFileUpload { (file) in
                    progress(file)
                }
                
                let operation = BackendOperation(model: nil, request: BackendReqestRegister.Example.upload, uploadFile)
                
                operation.onSuccess = {(json, status) in
                    
                    self?.fileController?.unsubscribe(fileId: uploadFile.fileId ?? "", removeFromPool: true)
                    response(true)
                }
                
                operation.onFailure = {(error, status) in
                    
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    UIApplication.topViewController().present(alert, animated: true, completion: nil)
                    self?.fileController?.unsubscribe(fileId: uploadFile.fileId ?? "", removeFromPool: true)
                    response(false)
                }
                
                self?.queue?.addOperation(operation: operation)
            }
        }
         */
    }
}
