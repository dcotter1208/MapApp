//
//  LogInTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInTVC: UITableViewController {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Firebase Error Handling:
    func handleFirebaseErrorCode(error: NSError?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
            switch errorCode {
            case .ErrorCodeWrongPassword:
                Alert().displayGenericAlert("Log In Failed.", message: "Wrong password. Please try again.", presentingViewController: self)
            case .ErrorCodeNetworkError:
                Alert().displayGenericAlert("Log In Failed", message: "Please check your network connection.", presentingViewController: self)
            case .ErrorCodeTooManyRequests:
                Alert().displayGenericAlert("Log In Failed", message: "Too many failed attempts.", presentingViewController: self)
            default:
                Alert().displayGenericAlert("Log In Failed", message: "Please try again.", presentingViewController: self)
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func logIn(sender: AnyObject) {
        if let email = emailTF.text, password = passwordTF.text {
            FirebaseOperation().loginWithEmailAndPassword(email, password: password) {
                (error) in
                guard error == nil else {
                    self.handleFirebaseErrorCode(error)
                    return
                }
            }
        }

    }

    @IBAction func continueAnonymously(sender: AnyObject) {
        print("anonymous")
    }
}
