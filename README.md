# Intellex

[![N|Solid](https://0.s3.envato.com/files/133274193/intellex%20mascot.png)](https://intellex.rs/)

Project aim is creating layer between backend operation and view controllers

## Features
- Separating request from opeartion
- All backend request implement protocol with predefined request methods
- Backend opearations can be combine in different order (setting dependencies) in Service class
- Backend operation are created around as NSOperation and every opeartion can cancel, resume and pause
- Downloading and uploading files and tracking load progress
- Executor class can be Alamofire, NSURLSession and Firebase, based on your need

## Requirements

- Swift 3
- min iOS 9 
- **Cocoa pods** 
- Alamofire (based on executor class):
- -  pod 'Alamofire', '~> 4.4.0'
-  Firebase pods (based on executor class):
- - pod 'Firebase/Core',
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'FirebaseUI/Database'
pod 'Firebase/Storage'
- ObjectMapper (requred):  
- - pod 'ObjectMapper', '~> 2.2'


> Based on type of executor you can install pod you will use in app. 

## Installation

Download files and drag in into project. Install required pods files.

## Usage
All code is organize around backend operation (NSOperation) and Services which can organize operations into single function. 
Every operation has:
- Request (NSObject class which implement BackendRequest protocol)
- Executor (NSObject class which implement BackendExecutor protocol)
- Success and Failure callback

Service is defining organization of muliple operations into single function.
Idea of services is to organize common operations into single class.
Main service organizes is object ServiceRegistry, which has pointer to all services.

### REST 
Service function is creating operations and add it to backend operation queue.

**Create service**
```sh
func sync(success: @escaping FinishHandler){
// Create operation
let operation = BOAllCategories()

// Operation success calback
operation.onSuccess = { (data, status) in

print(data as Any)
self.categories = ModelParser.parseArray(data: data!,type: Category.self)
success()
}

// Operation failure calback
operation.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
operation.cancel()
}

// Add operation to queue
self.queue?.addOperation(operation: operation)
}
```

**Adding dependecies between operations**
We are crating 4 operations plus one operation which indicates that all operations are finished. On the end of the functions we are declaring which operations is dependent from other operation.
```sh
func sync(success: @escaping FinishHandler){

// Operation that indicates that all operations are finished
let finishOperation = BlockOperation {

print("This is finished")
success()
}

// Create operation
let operation = BOAllCategories()
operation.onSuccess = { (data, status) in

print(data as Any)
self.categories = ModelParser.parseArray(data: data!,type: Category.self)
}
operation.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
operation.cancel()
}

// Async operation
let operationStoreCategories = BlockOperation {

if self.categories != nil{
CoreDataManager.storeCategories(categories: self.categories!, finish: { (finish) in })
}
}

// Get notifications
let operation2 = BOAllNotifications()
operation2.onSuccess = { (data, statusCode) in

print(data as Any)
self.notifications = ModelParser.parseArray(data: data!, type: AppNotification.self)
}

operation2.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
operation2.cancel()
}

let operationStoreNotifications = BlockOperation{

// Store all notifications
if self.notifications != nil && self.categories != nil{
CoreDataManager.storeSyncData(notifications: self.notifications!, finish: { (finish) in })
}
}

operationStoreCategories.addDependency(operation)
operation2.addDependency(operationStoreCategories)
operationStoreNotifications.addDependency(operation2)
finishOperation.addDependency(operationStoreNotifications)

self.queue?.addOperations(operations: [operation, operation2, operationStoreNotifications, operationStoreCategories, finishOperation])
}
```

**Concurrent opeartions**
We can set several operations to be concurrent, and creting one indicator operation to indicate that all other operations are finished.
```sh
func sync(success: @escaping FinishHandler){

// Get categories
let finishOperation = BlockOperation {

print("This is finished")
success()
}

let operation = BOAllCategories()
operation.onSuccess = { (data, status) in

print(data as Any)
self.categories = ModelParser.parseArray(data: data!,type: Category.self)
}
operation.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
operation.cancel()
}

// Get notifications
let operation2 = BOAllNotifications()
operation2.onSuccess = { (data, statusCode) in

print(data as Any)
self.notifications = ModelParser.parseArray(data: data!, type: AppNotification.self)
}

operation2.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
operation2.cancel()
}

finishOperation.addDependency(operation)
finishOperation.addDependency(operation2)

self.queue?.addOperations(operations: [operation, operation2, finishOperation])
}
```

## Load file

To upload or download file, executor has predefined functions. To use this feature in Service class, we need to have pointer to FileLoadController. That will enable us to listen change on file we wanto to upload or download.
**Download**
```sh
func downloadFile(fileName: String, fileType: String, fileExtension: String, finish: @escaping (_ file : FileLoad?) -> Void){
// Create id for file to download it
let fileId = "\(fileType)/\(fileName).\(fileExtension)"

self.loadController = FileLoadController(fileId: fileId)
let file = FileLoad.getFile(fileId: fileId, data: NSData())

// Create operation
let operation = BODownloadFile(fileId: fileId, path: fileType, name: fileName, fileExtension: fileExtension)
operation.onSuccess = { (data, statusCode) in

if data != nil{
print(data!)
}

finish(file)
}

operation.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
finish(nil)
}

self.queue?.addOperation(operation: operation)

// Track state of file
loadController?.subscribeForFileUpload { (file) in
print(file.progress)
}
}
```

**Upload**
```sh
func uploadFile(fileName: String, fileType: String, fileExtension: String, data: NSData, finish : @escaping FinishHandler){

// Create controller for fileId
self.loadController = FileLoadController(fileId: fileId)
let file = FileLoad.getFile(fileId: fileId, data: data)

// Create operation
let operation = BOUploadFile(fileId: fileId, path: path, name: name, fileExtension: fExtens)
operation.onSuccess = { (data, statusCode) in

if data != nil{
print(data!)
}

finish()
}

operation.onFailure = { (error, statusCode) in

print(error?.localizedDescription as Any)
finish()
}

self.queue?.addOperation(operation: operation)

loadController?.subscribeForFileUpload { (file) in
print(file.progress)
}

}
```

