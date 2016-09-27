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
    
    //MARK: Helper Methods:
    fileprivate func instantiateViewController(_ viewControllerIdentifier: String) {
        print("Instantiate called")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let istantiatedVC = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
        self.present(istantiatedVC, animated: true, completion: nil)
    }
    
    //Firebase Error Handling:
    func handleFirebaseErrorCode(_ error: NSError?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
            switch errorCode {
            case .errorCodeWrongPassword:
                Alert().displayGenericAlert("Log In Failed.", message: "Wrong password. Please try again.", presentingViewController: self)
            case .errorCodeNetworkError:
                Alert().displayGenericAlert("Log In Failed", message: "Please check your network connection.", presentingViewController: self)
            case .errorCodeTooManyRequests:
                Alert().displayGenericAlert("Log In Failed", message: "Too many failed attempts.", presentingViewController: self)
            default:
                Alert().displayGenericAlert("Log In Failed", message: "Please try again.", presentingViewController: self)
            }
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func logIn(_ sender: AnyObject) {
        if let email = emailTF.text, let password = passwordTF.text {
            FirebaseOperation().loginWithEmailAndPassword(email: email, password: password, completion: {
                (currentUser, error) in
                guard error == nil else {
                    self.handleFirebaseErrorCode(error)
                    return
                }
                self.instantiateViewController("MapVCNavController")
            })
        }
    }

    @IBAction func continueAnonymously(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
