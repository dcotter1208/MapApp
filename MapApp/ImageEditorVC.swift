//
//  SignUpProfileImageVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 12/30/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class ImageEditorVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!

    var imageSourceType: UIImagePickerControllerSourceType?
    let imagePicker = ImagePicker()
    fileprivate var profileImage: UIImage?
    fileprivate var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.imagePicker.delegate = self
        Alert.presentMediaActionSheet(presentingViewController: self, imagePicker: imagePicker.imagePicker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentImageSourceType() {
        guard let sourceType = imageSourceType else { return }
        switch sourceType {
        case .camera:
            presentCamera()
        case .photoLibrary:
            presentPhotoLibrary()
        default:
            presentPhotoLibrary()
        }
    }
    
    func presentCamera() {
        imagePicker.configureImagePicker(.camera)
        imagePicker.presentCameraSource(self)
    }
    
    func presentPhotoLibrary() {
        imagePicker.configureImagePicker(.photoLibrary)
        imagePicker.presentCameraSource(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        profileImage = pickedImage
        if let image = profileImage {
        self.profileImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) { 
            Alert.presentMediaActionSheet(presentingViewController: self, imagePicker: self.imagePicker.imagePicker)
        }
    }

    //displays action sheet for the camera or photo gallery
    func displayCameraActionSheet() {
        let imagePicker = ImagePicker()
        imagePicker.imagePicker.delegate = self
        self.imagePicker.imagePicker.allowsEditing = true
        
        let actionsheet = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentCamera()
        }
        let photoGallery = UIAlertAction(title: "Photo Gallery", style: .default) { (action) in
            imagePicker.configureImagePicker(.photoLibrary)
            imagePicker.presentCameraSource(self)
            self.presentPhotoLibrary()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionsheet.addAction(camera)
        actionsheet.addAction(photoGallery)
        actionsheet.addAction(cancel)
        self.present(actionsheet, animated: true, completion: nil)
    }

    @IBAction func saveImage(_ sender: Any) {
        
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
