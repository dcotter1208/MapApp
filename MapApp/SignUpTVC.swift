//
//  SignUpTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpTVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    private var profileImageChanged: Bool?
    private var imagePicker = UIImagePickerController()
    private var profileImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        profileImageChanged = false
    }
    
    //MARK: Helper Methods

    private func checkForCurrentUser() {
        if CurrentUser.sharedInstance.name != "" {
            
        }
    }
    
    private func instantiateViewController(viewControllerIdentifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let istantiatedVC = storyboard.instantiateViewControllerWithIdentifier(viewControllerIdentifier)
        self.presentViewController(istantiatedVC, animated: true, completion: nil)
    }
    
    private func removeWhiteSpace(string:String?, removeAllWhiteSpace:Bool) -> String {
        guard let string = string else {return "nil"}
        guard removeAllWhiteSpace == false else {
            let newString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "")
            return newString
        }
        let newString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return newString
    }
    
    
    //Alert used for failed signup
    func displayAlert(title: String, message: String) {
        Alert().displayGenericAlert(title, message: message, presentingViewController: self)
    }
    
    //displays action sheet for the camera or photo gallery
    func displayCameraActionSheet() {
        let imagePicker = ImagePicker()
        imagePicker.imagePicker.delegate = self
        let actionsheet = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .ActionSheet)
        let camera = UIAlertAction(title: "Camera", style: .Default) { (action) in
            imagePicker.configureImagePicker(.Camera)
            imagePicker.presentCameraSource(self)
        }
        let photoGallery = UIAlertAction(title: "Photo Gallery", style: .Default) { (action) in
            imagePicker.configureImagePicker(.PhotoLibrary)
            imagePicker.presentCameraSource(self)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionsheet.addAction(camera)
        actionsheet.addAction(photoGallery)
        actionsheet.addAction(cancel)
        self.presentViewController(actionsheet, animated: true, completion: nil)
    }
    
    //MARK: Camera Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        profileImageChanged = true
        profileImageView.image = pickedImage
        profileImage = pickedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Firebase Methods
    
    //Firebase Error Handling:
    func handleFirebaseErrorCode(error: NSError?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
            switch errorCode {
            case .ErrorCodeInvalidEmail:
                Alert().displayGenericAlert("Whoops!", message: "Invalid Email.", presentingViewController: self)
            case .ErrorCodeEmailAlreadyInUse:
                Alert().displayGenericAlert("Whoops!", message: "Email is already in use.", presentingViewController: self)
            case .ErrorCodeWeakPassword:
                Alert().displayGenericAlert("Whoops!", message: "Please pick a stronger password", presentingViewController: self)
            case .ErrorCodeNetworkError:
                Alert().displayGenericAlert("Sign Up Failed.", message: "Please check your connection.", presentingViewController: self)
            default:
                Alert().displayGenericAlert("Something went wrong.", message: "Please try again.", presentingViewController: self)
            }
        }
    }
    
    //Signs up user with firebase with profile image:
    func signUpFirebaseUserWithProfileImage(email: String, password: String, name: String) {
        FirebaseOperation().signUpWithEmailAndPassword(email, password: password, name: name, profileImageChoosen: true, profileImage: profileImage) {
            (error) in
            guard error == nil else {
                self.handleFirebaseErrorCode(error)
                return
            }
            self.instantiateViewController("MapVCNavController")
        }
    }
    
    //Signs up user with firebase with profile image:
    func signUpFirebaseUserWithNoProfileImage(email: String, password: String, name: String) {
        FirebaseOperation().signUpWithEmailAndPassword(email, password: password, name: name, profileImageChoosen: false, profileImage: nil) {
            (error) in
            guard error == nil else {
                self.handleFirebaseErrorCode(error)
                return
            }
            self.instantiateViewController("MapVCNavController")
        }
    }
    
    @IBAction func profileImageSelected(sender: AnyObject) {
        displayCameraActionSheet()
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        let name = removeWhiteSpace(nameTF.text, removeAllWhiteSpace: false)
        let email = removeWhiteSpace(emailTF.text, removeAllWhiteSpace: true)
        let password = removeWhiteSpace(passwordTF.text, removeAllWhiteSpace: true)
        guard name.characters.count > 2 else {
            displayAlert("Whoops!", message: "Your name must be longer than 2 characters")
            return
        }
        guard profileImageChanged == true else {
            self.signUpFirebaseUserWithNoProfileImage(email, password: password, name: name)
            return
        }
        self.signUpFirebaseUserWithProfileImage(email, password: password, name: name)
    }
    
    
    

}
