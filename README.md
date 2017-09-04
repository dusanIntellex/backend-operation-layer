# Intellex - Backend operation layer

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



