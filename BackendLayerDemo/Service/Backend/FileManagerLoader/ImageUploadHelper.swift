//
//  ImageUploadHelper.swift
//  Virtuzone
//
//  Created by Apple on 2/9/18.
//  Copyright © 2018 Quantox. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

typealias FileUploadHandler = ((FileLoad?) -> ())

class ImageUploadHelper: NSObject {

    static var fileUpload: FileUploadHandler?
    
    static func getDataFromLibraryItem(url: URL, response: @escaping (_ data: Data?) -> Void) {
        
        if let phAsset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).lastObject{
            
            PHImageManager.default().requestImageData(for: phAsset, options: nil) { (data, _, _, _) in
                
                response(data)
            }
        }
        else{
            response(nil)
        }
    }
    
    static func createUploadFile(imageInfo: [String: Any], imageSource: UIImagePickerControllerSourceType, response: @escaping FileUploadHandler){
        
        fileUpload = response
        if imageSource == .camera{
            storeFile(info: imageInfo)
        }
        else{
            createFileFromLibraryImage(info: imageInfo)
        }
    }
    
    private static func createFileFromLibraryImage(info: [String: Any]){
        
        let imageUrl = info[UIImagePickerControllerReferenceURL]
        imageFromAssetURL(assetURL: imageUrl as! URL)
    }
    
    static func imageFromAssetURL(assetURL: URL) {
        
        let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil)
        if asset.count != 0{
            getUrl(asset: asset.firstObject!)
        }
    }
    
    private static func storeFile(info : [String: Any]){
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else{
            if fileUpload != nil{
                fileUpload!(nil)
            }
        }
    }
    
    @objc static func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
            
            if fileUpload != nil{
                fileUpload!(nil)
            }
        } else {
            fetchLastImage()
        }
    }
    
    static func fetchLastImage()
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if (fetchResult.firstObject != nil)
        {
            let lastImageAsset: PHAsset = fetchResult.firstObject!
            getUrl(asset: lastImageAsset)
        }
        else{
            if fileUpload != nil{
                fileUpload!(nil)
            }
        }
    }
    
    static func getUrl(asset: PHAsset){
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.version = .current
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.resizeMode = .fast
        imageRequestOptions.isSynchronous = true
        
        PHImageManager.default().requestImageData(for: asset, options: imageRequestOptions) { (data, _, _, info) in
            
            guard info != nil else{
                if fileUpload != nil{
                    fileUpload!(nil)
                }
                return
            }
            
            if let _ = info!["PHImageFileURLKey"] as? NSURL {
                createFileUpload(info: info!, data: data)
            }
            else{
                if fileUpload != nil{
                    fileUpload!(nil)
                }
            }
        }
    }
    
    private static func createFileUpload(info: [AnyHashable: Any], data : Data?){
        
        print(info)
        if let url = info["PHImageFileURLKey"] as? NSURL{
            var fileExt = ""
            var fileName = ""
            if let parts = url.lastPathComponent?.components(separatedBy: "."){
                if parts.count > 1{
                    fileName = parts[0]
                    fileExt = parts[1]
                }
            }
            
            let file = FileLoad(fileId: url.lastPathComponent ?? "")
            file.path = url as URL
            file.data = data
            file.fileExtension = fileExt
            file.name = fileName
            file.type = "image"
            
            if fileUpload != nil{
                fileUpload!(file)
            }
        }
        else{
            if fileUpload != nil{
                fileUpload!(nil)
            }
        }
    }
    
}
