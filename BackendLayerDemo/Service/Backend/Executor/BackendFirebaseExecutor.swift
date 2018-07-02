//
//  BackendFirebaseExecutor.swift
//  AuthorizationApp
//
//  Created by Vladimir Djokanovic on 8/16/17.
//  Copyright © 2017 Intellex. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class BackendFirebaseExecutor: NSObject, BackendExecutorProtocol {
    
    var ref: DatabaseReference?
    var storage =  Storage.storage()
    var uploadTask : StorageUploadTask?
    var downloadTask : StorageDownloadTask?
    
    /// Execute backend REST request with firebase wrapper
    ///
    /// - Parameters:
    ///   - backendRequest: Request with all params
    ///   - successCallback: Return data and status code
    ///   - failureCallback: Return error and status code
    func executeBackendRequest(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        if ref == nil{
            ref = Database.database().reference()
        }
        
        backendRequestWithFirebase(backendRequest: backendRequest) { (data, error) in
            
            if error == nil{
                successCallback(data, 200)
            }
            else{
                failureCallback(error, 0)
            }
        }
    }
    
    /// Upload file with unique file id, data to be uplaoded, headers and completion block. Upload progress and status is tracked on file which containe all data about upload progress
    ///
    /// - Parameters:
    ///   - fileId: Id of file
    ///   - data: File data
    ///   - headers: Header for upload
    ///   - successCallback: Return data and status code
    ///   - failureCallback: Return error and stts code
    func uploadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback) {
        
        guard let fileId = backendRequest.paramteres()?[BRFileIdConst] else {
            failureCallback(nil, 1001)
            return
        }
        
        // File located on disk
        let file = FileLoad.getFile(fileId: fileId as! String, data: nil)
        
        // Create a reference to the file you want to upload
        guard let riversRef = getFilePath(request: backendRequest) else {
            failureCallback(nil, 1001)
            return
        }
        
        // Upload the file to the path "images/rivers.jpg"
        uploadTask = riversRef.putFile(from: file.path!, metadata: nil) { metadata, error in
            
            if let error = error {
                
                print(error.localizedDescription)
                failureCallback(error, 400)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()
                print("Download URL: \(downloadURL?.path ?? "No url")")
                successCallback(metadata, 200)
            }
        }
        
        observerLoad(task: uploadTask, file: file, successCallback: successCallback, failureCallback: failureCallback)
    }
    
    /// Download file
    ///
    /// - Parameters:
    ///   - backendRequest: <#backendRequest description#>
    ///   - successCallback: <#successCallback description#>
    ///   - failureCallback: <#failureCallback description#>
    func downloadFile(backendRequest: BackendRequest, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback) {
    
        guard let fileId = backendRequest.paramteres()?[BRFileIdConst] else {
            failureCallback(nil, 1001)
            return
        }
        
        // File located on disk
        let file = FileLoad.getFile(fileId: fileId as! String, data: NSData())
        
        // Create a reference to the file you want to upload
        guard let riversRef = getFilePath(request: backendRequest) else {
            failureCallback(nil, 1001)
            return
        }
        
        // Download to the local filesystem
        downloadTask = riversRef.write(toFile: file.path!) { url, error in
            
            if let error = error {
                
                print(error.localizedDescription)
                failureCallback(error, 400)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                print("Local URL: \(String(describing: url))")
                successCallback(url, 200)
            }
        }
        
        // Observer changes
        observerLoad(task: downloadTask, file: file, successCallback: successCallback, failureCallback: failureCallback)
    }
    

    // MARK: - Task manage
    
    func cancel(){
        ref?.cancelDisconnectOperations()
        
        if uploadTask != nil{
            
            uploadTask!.cancel()
        }
        else if downloadTask != nil{
            
            downloadTask?.cancel()
        }
    }
    
    func pause(){
        
        if uploadTask != nil{
            
            uploadTask!.pause()
        }
        else if downloadTask != nil{
            
            downloadTask?.pause()
        }
    }
    
    func resume(){
     
        if uploadTask != nil{
            
            uploadTask!.resume()
        }
        else if downloadTask != nil{
            
            downloadTask?.resume()
        }
    }
    
    
    //MARK:- Private
    
    private func observerLoad(task: StorageObservableTask?, file: FileLoad, successCallback: @escaping BackendRequestSuccessCallback, failureCallback: @escaping BackendRequestFailureCallback){
        
        // Listen for state changes, errors, and completion of the upload.
        task?.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
            file.status = .progress
        }
        
        task?.observe(.pause) { snapshot in
            // Upload paused
            file.status = .pause
        }
        
        task?.observe(.progress) { snapshot in
            
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            file.status = .progress
            file.progress = CGFloat(percentComplete)
        }
        
        task?.observe(.success) { snapshot in
            // Upload completed successfully
            file.status = .success
        }
        
        task?.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    file.status = .fail
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    file.status = .fail
                    break
                case .cancelled:
                    file.status = .cancel
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    file.status = .fail
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    file.status = .fail
                    break
                }
                
                print(error.localizedDescription)
                failureCallback(error, error.code)
            }
        }
    }
    
    private func getFilePath(request: BackendRequest) -> StorageReference?{
        
        let storageRef = storage.reference()
        
        guard let name = request.paramteres()?[BRFileNameConst] as? String, let ext = request.paramteres()?[BRFileExtensionConst] as? String, let path = request.paramteres()?[BRFilePathConst] as? String else { return nil }
        
        return storageRef.child("\(path)/\(name).\(ext)")
    }
    
    private func backendRequestWithFirebase(backendRequest: BackendRequest, completion:@escaping (_ result : DataSnapshot?,_ error: Error?) -> Void){
        
        switch backendRequest.method() {
            
        case .get:
            
            // If you have need for getting whole database use ""
            if backendRequest.endpoint() == ""{
                
                // If we want to listen changes on current model
                if let observ = backendRequest.firebaseObserver(){
                    
                    if observ{
                        
                        ref!.observe(.value, with: { (snapshot) in
                            
                            completion(snapshot, nil)
                        })
                        
                        return
                    }
                }
                
                ref!.observeSingleEvent(of: .value, with: { (snapshot) in
                    completion(snapshot, nil)
                })
                
            }
            else{
                
                // If we want to listen changes on current model
                if let observ = backendRequest.firebaseObserver(){
                    
                    if observ{
                        
                        ref!.child(backendRequest.endpoint()).observe( .value) { (snapshot) in
                            
                            completion(snapshot, nil)
                        }
                    }
                    
                    return
                }
                
                ref!.child(backendRequest.endpoint()).observeSingleEvent(of: .value, with: { (snapshot) in
                    completion(snapshot, nil)
                })
            }
            break
            
        case .post:
            
            ref!.child(backendRequest.endpoint()).updateChildValues(backendRequest.paramteres()!, withCompletionBlock: { (error, reference) in
                
                completion(nil, error)
            })
            
            break
        default:
            break
        }
    }
    
}
