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
    
    
    func uploadFile(file: FileLoad, response: @escaping SuccessCallback){
        
//        let operation = BOUploadExample()

    }
    
    func downloadFile(response: @escaping SuccessCallback, progress: @escaping (_ file : FileLoad) -> Void){

        let operation = BODownloadExample()
        
        operation.onSuccess = {(file, status) in
            
            self.fileController?.unsubscribe(fileId: (operation.request as? DownloadFileProtocol)?.downloadFileId() ?? "")
            response(((file as? FileLoad) != nil))
        }
        
        operation.onFailure = {(error, status) in
            
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
            self.fileController?.unsubscribe(fileId: (operation.request as? DownloadFileProtocol)?.downloadFileId() ?? "")
            response(false)
        }
        
        self.queue?.addOperation(operation: operation)
        
        // Track progress
        fileController = FileLoadController.init(fileId: (operation.request as? DownloadFileProtocol)?.downloadFileId() ?? "")
        fileController?.subscribeForFileUpload { (file) in
            progress(file)
        }
    }
}
