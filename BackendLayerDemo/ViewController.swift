//
//  ViewController.swift
//  BackendLayerDemo
//
//  Created by Apple on 11/13/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loadProgressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button actions
    
    @IBAction func requestAction(_ sender: UIButton) {
        
        ServiceRegister.sharedInstance.example.getRestExample { (data) in
            
            if let dict = data as? [String: Any]{
                let alert = UIAlertController(title: "Success", message: dict["body"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func downloadAction(_ sender: UIButton) {
        
        ServiceRegister.sharedInstance.example.downloadFile(response: { (succes) in
            if succes{
                let alert = UIAlertController(title: "Success", message: "File successfuly downloaded", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }) { (file) in
            
            self.loadProgressLabel.text = "\(Double(round(100*file.progress))/100)"
            
            switch file.status{
            case .pending:
                self.loadProgressLabel.textColor = UIColor.lightGray
                break
            case .fail:
                self.loadProgressLabel.textColor = UIColor.red
                break
            case .success:
                self.loadProgressLabel.textColor = UIColor.green
                break
            case .progress:
                self.loadProgressLabel.textColor = UIColor.blue
                break
            default:
                self.loadProgressLabel.textColor = UIColor.gray
                break
            }
            
            
        }
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
    }
}

