//
//  ExampleService.swift
//  BackendLayerDemo
//
//  Created by Apple on 4/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ExampleService: BackendService {
    
    private var fileController: FileLoadController?

    
    func getRestExample(response: @escaping (_ dataResponse: Any?) -> Void){
        
        let operation = BORestExample()
        
        operation.onSuccess = {(data, status) in
            
            response(data)
        }
        
        operation.onFailure = {(error, status) in
            
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
            
            response(nil)
        }
        
        self.queue?.addOperation(operation: operation)
    }
    
    func downloadFile(response: @escaping (_ responseFile: FileLoad?) -> Void, progress: @escaping (_ file : FileLoad) -> Void){

        let operation = BODownloadExample()
        
        operation.onSuccess = {(file, status) in
            
            self.fileController?.unsubscribe(fileId: (operation.request as? DownloadFileProtocol)?.downloadFileId() ?? "", removeFromPool: true)
            response(file as? FileLoad)
        }
        
        operation.onFailure = {(error, status) in
            
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
            self.fileController?.unsubscribe(fileId: (operation.request as? DownloadFileProtocol)?.downloadFileId() ?? "", removeFromPool: true)
            response(nil)
        }
        
        self.queue?.addOperation(operation: operation)
        
        // Track progress
        fileController = FileLoadController.init(fileId: (operation.request as? DownloadFileProtocol)?.downloadFileId() ?? "")
        fileController?.subscribeForFileUpload { (file) in
            progress(file)
        }
    }
    
    func uploadFile(uploadFile: FileLoad, response: @escaping SuccessCallback,  progress: @escaping (_ file : FileLoad) -> Void){
        
        GoogleClient.authorize { [unowned self] (success) in

            if success{

                // Track progress
                self.fileController = FileLoadController.init(fileId: uploadFile.fileId ?? "")
                self.fileController?.subscribeForFileUpload { (file) in
                    progress(file)
                }
                
                
                let operation = BOUploadExample(file: uploadFile)
                
                operation.onSuccess = {(json, status) in
                    
                    self.fileController?.unsubscribe(fileId: uploadFile.fileId ?? "", removeFromPool: true)
                    response(true)
                }
                
                operation.onFailure = {(error, status) in
                    
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    UIApplication.topViewController().present(alert, animated: true, completion: nil)
                    self.fileController?.unsubscribe(fileId: uploadFile.fileId ?? "", removeFromPool: true)
                    response(false)
                }
                
                self.queue?.addOperation(operation: operation)
            }
            
            
        }
    }
}
