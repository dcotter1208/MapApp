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

    
    typealias filteredImageResult = (UIImage) -> Void
    
    var imageForMessage: UIImage?
    var imagePicker = UIImagePickerController()
    let firebaseOperation = FirebaseOperation()
    var venueID: String?
    var currentUserID = ""
    var filteredImage: UIImage?
    var imageFilters = [ImageFilter]()
    var filteredImages = [UIImage]()
    
//    case redSky = "CISepiaTone"
//    case blackAndWhite = "CIPhotoEffectNoir"
//    case effectiveness = "CIPhotoEffectProcess"
//    case chromedOut = "CIPhotoEffectChrome"
//    case tonal = "CIPhotoEffectTonal"
//    case instant = "CIPhotoEffectInstant"
//    case fade = "CIPhotoEffectFade"
//    case transfer = "CIPhotoEffectTransfer"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageFilters = [.redSky, .blackAndWhite, .effectiveness, .chromedOut, .tonal, .instant, .fade, .transfer]
        
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
        DispatchQueue.main.async {
            self.mediaImageView.image = image
        }
        createArrayOfFilteredImagesWithImage(image: image)
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
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilteredImage = filteredImages[indexPath.item]
        mediaImageView.image = selectedFilteredImage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageForFilter = filteredImages[indexPath.item]
        let filterCell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
        let cellImageView = filterCell.viewWithTag(102) as! UIImageView
            cellImageView.image = imageForFilter
        return filterCell
    }

    func createArrayOfFilteredImagesWithImage(image: UIImage) {
        
        filteredImages.append(image)
        
        guard let cgImg = image.cgImage else { return }
    
        for filter in imageFilters {
            let openGLContext = EAGLContext(api: .openGLES2)
            let context = CIContext(eaglContext: openGLContext!)
            let coreImage = CIImage(cgImage: cgImg)
            
            let filter = CIFilter(name: filter.rawValue)
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            
            if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let cgimgresult = context.createCGImage(output, from: output.extent)
                let result = UIImage(cgImage: cgimgresult!)
                filteredImages.append(result)
                if filteredImages.count == imageFilters.count + 1 {
                self.filterCollectionView.reloadData()
                }
            }
        }
    }
    
}
