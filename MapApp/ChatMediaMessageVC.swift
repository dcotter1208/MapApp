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
        dismiss(animated: true, completion: nil)
        imageForMessage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard let image = imageForMessage else { return }
        DispatchQueue.main.async {
            self.mediaImageView.image = image
            self.createArrayOfFilteredImagesWithImage(image: image)
        }
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
        let imageWithFilter = filteredImages[indexPath.item]
        let filterCell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
        let cellImageView = filterCell.viewWithTag(102) as! UIImageView
        cellImageView.image = nil
        DispatchQueue.main.async {
         cellImageView.image = imageWithFilter
        }
        return filterCell
    }

    func createArrayOfFilteredImagesWithImage(image: UIImage) {
        let imageScale = image.scale
        let imageOrientation = image.imageOrientation
        filteredImages.append(image)
        
        guard let cgImg = image.cgImage else { return }

        let coreImage = CIImage(cgImage: cgImg)
        
        for filter in imageFilters {

            let filter = CIFilter(name: filter.rawValue)
            filter?.setValue(coreImage, forKey: kCIInputImageKey)
            
            if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let cgimgresult = context?.createCGImage(output, from: output.extent)
                if let CGImgResult = cgimgresult {
                    let result = UIImage(cgImage: CGImgResult, scale: imageScale, orientation: imageOrientation)
                    filteredImages.append(result)
                    if filteredImages.count == imageFilters.count + 1 {
                        self.filterCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
}
