    //
//  ViewController.swift
//  BackendLayerDemo
//
//  Created by Apple on 11/13/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import UserNotifications
import MobileCoreServices
import BackendServiceAdapter
import RxSwift

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var loadProgressLabel: UILabel!
    var dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerForNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button actions
    
    @IBAction func requestAction(_ sender: UIButton) {
        
        ServiceRegister.sharedInstance.example.getRestExample()
            .subscribe(onNext: { (value) in
                print(value)
            }, onError: { [weak self] (error) in
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                
            }, onCompleted: {
                print("Completed")
            }, onDisposed: {
                print("Disposed")
            })
            .disposed(by: dispose)
    }
    
    @IBAction func postRequestAction(_ sender: UIButton) {
        let sendingModel = ExampleModel(id: 999991, name: "test")
        ServiceRegister.sharedInstance.example.postRestExample(exampleModel: sendingModel) { [weak self] (data) in
            if let dict = data as? [String: Any]{
                let alert = UIAlertController(title: "Success", message: dict["body"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func downloadAction(_ sender: UIButton) {
        
        ServiceRegister.sharedInstance.example.downloadFile(response: { [weak self] (downloadedFile) in
            if downloadedFile != nil{
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Success", message: "File successfuly downloaded.\nYou can find it on url: \(downloadedFile?.path?.absoluteString ?? "")", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }) { [weak self] (file) in
            
            DispatchQueue.main.async {
                self?.loadProgressLabel.text = "\(Double(round(100*file.progress))/100)"
                
                switch file.status{
                case .pending:
                    self?.loadProgressLabel.textColor = UIColor.lightGray
                    break
                case .fail:
                    self?.loadProgressLabel.textColor = UIColor.red
                    break
                case .success:
                    self?.loadProgressLabel.textColor = UIColor.green
                    break
                case .progress:
                    self?.loadProgressLabel.textColor = UIColor.blue
                    break
                default:
                    self?.loadProgressLabel.textColor = UIColor.gray
                    break
                }
            }
        }
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        getImage()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        ImageUploadHelper.createUploadFile(imageInfo: info as [String : Any], imageSource: picker.sourceType,
                                           response: { [weak self] file in
                                            if file != nil{
                                                self?.uploadFile(file: file!)
                                            }
            },
                                           error: { [weak self] error in
                                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                                            self?.present(alert, animated: true, completion: nil)
        })
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadFile(file: FileLoad){
        
        ServiceRegister.sharedInstance.example.uploadFile(uploadFile: file, response: { [weak self] (success) in
            
            if success{
                let alert = UIAlertController(title: "Success", message: "File successfuly uploaded", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            
        }) { [weak self] (file) in
            
            DispatchQueue.main.async {
                self?.loadProgressLabel.text = "\(Double(round(100*file.progress))/100)"
                
                switch file.status{
                case .pending:
                    self?.loadProgressLabel.textColor = UIColor.lightGray
                    break
                case .fail:
                    self?.loadProgressLabel.textColor = UIColor.red
                    break
                case .success:
                    self?.loadProgressLabel.textColor = UIColor.green
                    break
                case .progress:
                    self?.loadProgressLabel.textColor = UIColor.blue
                    break
                default:
                    self?.loadProgressLabel.textColor = UIColor.gray
                    break
                }
            }
        }
        
    }
    
    func getImage(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        
        AlertHelper.alertWithTwoOptionsAndCancel(NSLocalizedString("Select file to upload", comment: ""), message: NSLocalizedString("Select source ", comment: ""), closeTitle: NSLocalizedString("Photos", comment: ""), actionTitle: NSLocalizedString("Camera", comment: ""), closeButton: {
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.sourceType = .photoLibrary;
                UIApplication.topViewController().present(imagePicker, animated: true, completion: nil)
            }
            
        }) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera;
                UIApplication.topViewController().present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    
    private func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
    }
}

