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
import Kingfisher

public typealias FileUploadHandler = ((FileLoad?) -> ())
let IMAGE_MAX_SIZE = 2000 // size in KB

public class ImageUploadHelper: NSObject {

    enum ImageUploadError: Error{
        case imagesaveError(String)
        
    }
    
    public static var fileUpload: FileUploadHandler?
    static var errorHandler: ErrorCallback!
    
    public static func createUploadFile(imageInfo: [String : Any], imageSource: UIImagePickerController.SourceType, response: @escaping FileUploadHandler, error: @escaping ErrorCallback) {
        
        fileUpload = response
        errorHandler = error
        storeFile(info: imageInfo)
    }
    
    private static func storeFile(info : [String : Any]){
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            UIImageWriteToSavedPhotosAlbum(resizeImage(image: image), self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else{
            if fileUpload != nil{
                fileUpload!(nil)
            }
        }
    }
    
    @objc static func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler(error)
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
        

        if let url = info["PHImageFileURLKey"] as? NSURL{
            var fileExt = ""
            var fileName = ""
            if let parts = url.lastPathComponent?.components(separatedBy: "."){
                if parts.count > 1{
                    fileName = parts[0]
                    fileExt = parts[1]
                }
            }
            
            let file = FileLoad(fileName: fileName, path: url as URL, fileExtension: fileExt, fileId: url.lastPathComponent ?? "")
            file.data = data
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
    
    private static func resizeImage(image: UIImage) -> UIImage{
        
        var resizeImage = image
        
        while (UIImagePNGRepresentation(resizeImage)!.count / 1024) > IMAGE_MAX_SIZE{
            let resizeScale = resizeImage.scale - 0.1
            resizeImage = image.kf.resize(to: CGSize(width: resizeImage.size.width * resizeScale, height: resizeImage.size.height * resizeScale), for: .aspectFill)
        }
        
        return resizeImage
    }
}
