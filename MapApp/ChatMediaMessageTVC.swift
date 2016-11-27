//
//  ChatMediaMessageTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/12/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import Cloudinary
import FirebaseAuth

class ChatMediaMessageTVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLUploaderDelegate {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var imageForMessage: UIImage?
    var imagePicker = UIImagePickerController()
    let firebaseOperation = FirebaseOperation()
    var venueID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        Alert.presentMediaActionSheet(presentingViewController: self, imagePicker: imagePicker)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        imageForMessage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard let image = imageForMessage else { return }
        self.mediaImageView.image = image
    }

    func saveMessageToFirebaseAndCloudinary() {
        guard let media = imageForMessage else { return }
        
        var currentUserID = ""
        if CurrentUser.sharedInstance.userID == "" {
            if let anonymousUserID = FIRAuth.auth()?.currentUser?.uid {
                currentUserID = anonymousUserID
            }
        } else {
            currentUserID = CurrentUser.sharedInstance.userID
        }

        CloudinaryOperation().uploadImageToCloudinary(media, delegate: self, completion: {
            (photoURL) in
            if let venueID = self.venueID {
                let mediaMessage = ["text" : self.messageTextView.text, "timestamp" : "", "locationID" : venueID, "userID" : currentUserID, "mediaURL" : photoURL, "messageType" : MessageType.media.rawValue] as [String : Any]
                self.firebaseOperation.setValueForChild(child: "messages", value: mediaMessage)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendPressed(_ sender: Any) {
        if mediaImageView.image != nil {
            saveMessageToFirebaseAndCloudinary()
        }
    }

}
