//
//  GoogleClient.swift
//  Uzoni
//
//  Created by Dusan Cucurevic on 3/25/17.
//  Copyright © 2017 DusanCucurevic. All rights reserved.
//

import UIKit
import GoogleSignIn

class GoogleClient: NSObject, GIDSignInDelegate, GIDSignInUIDelegate  {
    
    var success : SuccessCallback?
    
    static let sharedInstance = GoogleClient()
    
    static func authorize(successHandler: @escaping SuccessCallback){
        
        sharedInstance.success = successHandler
        
        // GoogleSignIn
        GIDSignIn.sharedInstance().clientID = "408860784888-bd9m1hfdaobl149ufdohe3qhpds4mvit.apps.googleusercontent.com"
        
        // Google delegate
        GIDSignIn.sharedInstance().delegate = sharedInstance
        GIDSignIn.sharedInstance().uiDelegate = sharedInstance
        
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/drive"]
        GIDSignIn.sharedInstance().signIn()
    }
    
    static func logout(){
        
        GIDSignIn.sharedInstance().signOut()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            
            if let accessToken = user.authentication.accessToken {
                
                print("Google token \(accessToken)")
                GoogleClient.sharedInstance.success!(true)
            }
            else{
                
                GoogleClient.sharedInstance.success!(false)
            }
        }
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let alert = UIAlertController(title: "Logout", message: "User is logout", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        UIApplication.topViewController().present(alert, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        UIApplication.topViewController().present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        UIApplication.topViewController().dismiss(animated: true, completion: nil)
    }
    
    
}

