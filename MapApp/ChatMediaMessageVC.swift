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
    var openGLContext: EAGLContext?
    var context: CIContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        setContextForFilter()
        
        imageFilters = [.redSky, .blackAndWhite, .effectiveness, .chromedOut, .tonal, .instant, .fade, .transfer]
        
        imagePicker.delegate = self
        Alert.presentMediaActionSheet(presentingViewController: self, imagePicker: imagePicker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setContextForFilter() {
        openGLContext = EAGLContext(api: .openGLES2)
        if let eaglContext = openGLContext {
            context = CIContext(eaglContext: eaglContext)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageForMessage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard let image = self.imageForMessage else { return }
        self.mediaImageView.image = image

        dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.createArrayOfFilteredImagesWithImage(image: image)
            }
        })
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
        let filterCell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
        let cellImageView = filterCell.viewWithTag(102) as! UIImageView
        cellImageView.image = nil
        
        DispatchQueue.global(qos: .background).async {
            let imageWithFilter = self.filteredImages[indexPath.item]
            let newSize = CGSize(width: imageWithFilter.size.width/2, height: imageWithFilter.size.height/2)
            let newImage = imageWithFilter.resizedImage(newSize)
            DispatchQueue.main.async {
                cellImageView.image = newImage
            }
        }
        return filterCell
    }
    
    func createArrayOfFilteredImagesWithImage(image: UIImage) {
        filteredImages.append(image)
        for filter in imageFilters {
            let filteredImageResult = image.applyFilter(filterType: filter, context: context)
            guard let filteredImgResult = filteredImageResult else { return }
                    filteredImages.append(filteredImgResult)
                    if filteredImages.count == imageFilters.count + 1 {
                        self.filterCollectionView.reloadData()
                }
            }
        }
}


