//
//  VenueDetailVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class VenueChatDisplayDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venuePhotosCollectionView: UICollectionView!
    @IBOutlet weak var starRatingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messagedTextField: UITextField!
    
    //TEST DATA***********
    
    let scrooged = User(name: "Frank Cross", location: "New York, NY", userID: "01", profileImageURL: "", profileImage: #imageLiteral(resourceName: "bill_murray_scrooged"))
    let ghostBuster = User(name: "Dr. Peter Venkman", location: "New York, NY", userID: "02", profileImageURL: "", profileImage: #imageLiteral(resourceName: "bill_murray_ghost"))
    let currentUser = User(name: "Donovan", location: "Clinton Twp", userID: "12345", profileImageURL: "", profileImage:#imageLiteral(resourceName: "current_user"))
    
    //TEST DATA***********

    var venuePhotos = [1, 2, 3, 4, 5, 6, 7] // Will be UIImage array
    var userPhotos = [1, 2, 3, 4, 5, 6, 7] // Will be UIImage array
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let message1 = Message(message: "I'm at HopCat annnnddd having crack fries of course.", user: scrooged, timestamp: "10/21/16, 8:24 PM")
        let message2 = Message(message: "Love crack fries", user: ghostBuster, timestamp: "10/21/16, 8:30 PM")
        let message3 = Message(message: "great music tonight...sicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, .Lorem ipsum dolor sitsicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, .Lorem ipsum dolor sit", user: ghostBuster, timestamp: "10/21/16, 8:30 PM")
        let message4 = Message(message: "This is the place to be! Wait was only 15 minutes.", user: scrooged, timestamp: "10/21/16, 8:41 PM")
        let message5 = Message(message: "130 beers on tap!", user: currentUser, timestamp: "10/21/16, 8:30 PM")
        let message6 = Message(message: "Try their 60 Minute IPA. One of the best I've had.", user: scrooged, timestamp: "10/21/16, 9:24 PM")
        let message7 = Message(message: "Had that last time... the Ghettoblaster is fantastic as well. Had that last time... the Ghettoblaster is fantastic as well.Had that last time... the Ghettoblaster is fantastic as well.Had that last time... the Ghettoblaster is fantastic as well. Had that last time... the Ghettoblaster is fantastic as well. Had that last time... the Ghettoblaster is fantastic as well.", user: currentUser, timestamp: "10/21/16, 9:48 PM")
        
        
        messages = [message1, message2, message3, message4, message5, message6, message7]
        
        messagedTextField.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.performSegue(withIdentifier: "FullChatViewSegue", sender: self)
    }
    //MARK: Venue CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == venuePhotosCollectionView {
            return venuePhotos.count
        } else {
            return userPhotos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == venuePhotosCollectionView {
            let venuePhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VenuePhotoCell", for: indexPath)
            let cellImageView = venuePhotoCell.viewWithTag(101) as? UIImageView
            cellImageView?.image = UIImage(named: "HopCat")
            return venuePhotoCell

        } else {
            let userPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPhotoCell", for: indexPath)
            let cellImageView = userPhotoCell.viewWithTag(101) as? UIImageView
            cellImageView?.image = UIImage(named: "HopCatUser")
            return userPhotoCell
        }
    }
    
    //MARK: Messages TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        guard message.user.userID == "12345" else {
            let defaultMessageCell = tableView.dequeueReusableCell(withIdentifier: "DefaultMessageCell", for: indexPath) as! DefaultMessageCell
            defaultMessageCell.setCellAttributesWithMessage(message: message)
            return defaultMessageCell
        }
        let currentUserMessageCell = tableView.dequeueReusableCell(withIdentifier: "CurrentUserMessageCell", for: indexPath) as! CurrentUserMessageCell
        currentUserMessageCell.setCellAttributesWithMessage(message: message)
        return currentUserMessageCell
    }

    //MARK: IBAction
    @IBAction func backButton(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func starRatingPressed(_ sender: AnyObject) {
        print("*****Star Rating Pressed****")
        
    }
    
    @IBAction func chatTextBarSelected(_ sender: AnyObject) {
        
    }
    
}
