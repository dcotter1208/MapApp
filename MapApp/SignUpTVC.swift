//
//  SignUpTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpTVC: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeWhiteSpace(string:String?, removeAllWhiteSpace:Bool) -> String {
        guard let string = string else {return "nil"}
        guard removeAllWhiteSpace == false else {
            let newString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "")
            return newString
        }
        let newString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return newString
    }
    
    
    //Alert used for failed signup
    func displayAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Firebase Error Handling:
    func handleFirebaseErrorCode(error: NSError?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
            switch errorCode {
            case .ErrorCodeInvalidEmail:
                self.displayAlert("Whoops!", message: "Invalid Email")
            case .ErrorCodeEmailAlreadyInUse:
                self.displayAlert("Whoops!", message: "Email is already in use.")
            case .ErrorCodeWeakPassword:
                self.displayAlert("Whoops!", message: "Please pick a stronger password.")
            case .ErrorCodeNetworkError:
                self.displayAlert("Sign Up Failed.", message: "Please check your connection.")
            default:
                print(error?.localizedDescription)
                self.displayAlert("Something went wrong.", message: "Please try again.")
            }
        }
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        let name = removeWhiteSpace(nameTF.text, removeAllWhiteSpace: false)
        let email = removeWhiteSpace(emailTF.text, removeAllWhiteSpace: true)
        let password = removeWhiteSpace(passwordTF.text, removeAllWhiteSpace: true)
        guard name.characters.count > 2 else {
            displayAlert("Whoops!", message: "Your name must be longer than 2 characters")
            return
        }
        
        FirebaseOperation().signUpWithEmailAndPassword(email, password: password, name: name, profileImageChoosen: false, profileImage: nil) {
            (error) in
            guard error == nil else {
                self.handleFirebaseErrorCode(error)
                return
            }
        }
        
    }
    
    
    

}
