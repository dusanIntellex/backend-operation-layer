//
//  AlertHelper.swift
//  NexoCams
//
//  Created by Apple on 10/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

/// Completion handlers
typealias FinishHandler = () -> Void
typealias SuccessHandler = (_ success: Bool) -> Void
typealias ButtonPressed = () -> Void
typealias TextFieldButtomPressed = (_ inputText: String) -> Void

class AlertHelper: NSObject {

    // MARK:- Alert
    
    /**
     Alert with title. One button is predefined ("OK")
     
     - parameter title:   Title message of alert
     - parameter message: Message of alert
     */
    static func alertWithTitle(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
            case .default:
                print("default")
                _ = UIApplication.topViewController().popoverPresentationController
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    /**
     Create tost with alert message. Tost will be removed after set duration
     
     - parameter title:    Title of alert tost
     - parameter message:  Message of alert tost
     - parameter duration: Duration of tost
     */
    static func alertTost(_ title: String, message: String, duration: Double) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
        
        let delayTime = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     Create alert with completion handler when button ok is pressed
     
     - parameter title:           Alert title
     - parameter message:         Alert message
     - parameter okButtonPressed: Block to be execute when button is pressed
     */
    static func alertWithButtonPresed(_ title: String, message: String, buttonTitle: String?, okButtonPressed: @escaping ButtonPressed) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle != nil ? buttonTitle : "OK", style: .default, handler: { action in
            
            switch action.style {
                
            case .default:
                print("default")
                _ = UIApplication.topViewController().popoverPresentationController
                okButtonPressed()
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    
    /// Alert view with text input field
    ///
    /// - parameter title:                Name of alert
    /// - parameter message:              Message
    /// - parameter buttonTitle:          Ok button title. Other button is cancel
    /// - parameter textFieldPlaceholder: TextField placeholder
    /// - parameter okButtonPressed:      Return value from textfield
    static func alertWithTextField(_ title: String, message: String, buttonTitle: String, textFieldPlaceholder: String, okButtonPressed: @escaping TextFieldButtomPressed){
        
        let alert = UIAlertController(title: title, message: message,preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = textFieldPlaceholder
        }
        
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (_) in
            
            _ = UIApplication.topViewController().popoverPresentationController
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (_) in
            let input = alert.textFields![0]
            
            if input.text != ""{
                okButtonPressed(input.text!)
            }
        }))
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    /**
     Create alert with two option.
     
     - parameter title:        The title of alert
     - parameter message:      The message of alert
     - parameter closeTitle:   Close button tile
     - parameter actionTitle:  Action button tile
     - parameter closeButton:  Close callback
     - parameter actionButton: Action callback
     */
    static func alertWithTwoOptions(_ title: String, message: String, closeTitle: String, actionTitle: String, closeButton: @escaping (ButtonPressed), actionButton: @escaping (ButtonPressed)) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: closeTitle, style: .default, handler: { action in
            
            closeButton()
        }))
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
            actionButton()
        }))
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    static func alertWithTwoOptionsAndCancel(_ title: String, message: String, closeTitle: String, actionTitle: String, closeButton: @escaping (ButtonPressed), actionButton: @escaping (ButtonPressed)) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: closeTitle, style: .default, handler: { action in
            
            closeButton()
        }))
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
            actionButton()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    static func alertSheetWithTwoOptions(_ message: String, firstTitle: String, secondTitle: String, firstAction: @escaping ButtonPressed, secondAction: @escaping ButtonPressed){
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: firstTitle, style: .default, handler: { action in
            
            firstAction()
        }))
        
        alert.addAction(UIAlertAction(title: secondTitle, style: .default, handler: { action in
            secondAction()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancle", comment: ""), style: .cancel, handler: nil))
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
    }
    
    
    
    /**
     Create tost with completion block after duration.
     
     - parameter title:    Title of alert
     - parameter message:  MEssage text
     - parameter duration: Duration of tost
     - parameter finish:   Block to be execute after duration
     */
    static func alertTostWithCompletionHandler(_ title: String, message: String, duration: Double, finish: @escaping SuccessHandler) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
        
        let delayTime = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            alert.dismiss(animated: true, completion: nil)
            finish(true)
        }
    }
    
    /**
     Alert view with "Not implemented" message
     */
    static func notImplemented() {
        
        let alert = UIAlertController(title: "NOT_IMPLEMENTED", message: nil, preferredStyle: .alert)
        
        DispatchQueue.main.async(execute: {
            UIApplication.topViewController().present(alert, animated: true, completion: nil)
        })
        
        let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
