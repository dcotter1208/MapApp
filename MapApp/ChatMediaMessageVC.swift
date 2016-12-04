//
//  ChatMediaMessageVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/12/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import Cloudinary
import FirebaseAuth

class ChatMediaMessageVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CLUploaderDelegate {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!

    var imageForMessage: UIImage?
    var imagePicker = UIImagePickerController()
    let firebaseOperation = FirebaseOperation()
    var venueID: String?
    var currentUserID = ""
    var filteredImage: UIImage?
    var imageFilters = [ImageFilter]()
    
//    case redSky = "CISepiaTone"
//    case colorSwap = "CIColorCrossPolynomial"
//    case beauty = "CIColorCubeWithColorSpace"
//    case blackAndWhite = "CIPhotoEffectNoir"
//    case effectiveness = "CIPhotoEffectProcess"
//    case chromedOut = "CIPhotoEffectChrome"
//    case heat = "CIColorMap"
//    case feelinBlue = "CIColorMonochrome"
//    case blur = "CIGaussianBlur"
//    case cali = "CIColorClamp"
//    case bright = "CIColorMatrix"
//    case mellow = "CITemperatureAndTint"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageFilters = [.redSky, .colorSwap, .beauty, .blackAndWhite, .effectiveness, .chromedOut, .heat, .feelinBlue, .blur, .cali, .bright, .mellow]
        
        imagePicker.delegate = self
        Alert.presentMediaActionSheet(presentingViewController: self, imagePicker: imagePicker)
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
        
        if CurrentUser.sharedInstance.userID == "" {
            if let anonymousUserID = FIRAuth.auth()?.currentUser?.uid {
                currentUserID = anonymousUserID
            }
        } else {
            currentUserID = CurrentUser.sharedInstance.userID
        }

        CloudinaryOperation().uploadImageToCloudinary(mediaImageView.image!, delegate: self, completion: {
            (photoURL) in
            guard let mediaMessage = self.createMediaMessageWithMediaURL(mediaURL: photoURL) else {
                //Send a failed to send message alert.
                return
            }
                self.firebaseOperation.setValueForChild(child: "messages", value: mediaMessage)
                self.dismiss(animated: true, completion: nil)
        })
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendPressed(_ sender: Any) {
        if mediaImageView.image != nil {
            saveMessageToFirebaseAndCloudinary()
        }
    }
    
    func createMediaMessageWithMediaURL(mediaURL: String) -> Dictionary<String, Any>? {

        guard let venueID = venueID else {
            return nil
        }
        
        let mediaMessage = ["timestamp" : "", "locationID" : venueID, "userID" : currentUserID, "mediaURL" : mediaURL, "messageType" : MessageType.media.rawValue] as [String : Any]
        
        return mediaMessage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        applyFilterAtIndexPath(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageFilter = imageFilters[indexPath.item]
        let filterCell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
        let cellLabel = filterCell.viewWithTag(101) as! UILabel
        cellLabel.text = imageFilter.rawValue
        return filterCell
    }
    
    func applyFilterAtIndexPath(indexPath: IndexPath) {
        let imageFilter = imageFilters[indexPath.item]
        
        
        mediaImageView.image? = (mediaImageView.image?.af_imageFiltered(withCoreImageFilter: imageFilter.rawValue))!
            let filteredImage = imageForMessage?.af_imageFiltered(withCoreImageFilter: imageFilter.rawValue)
            mediaImageView.image = filteredImage
        
    }
    
}
