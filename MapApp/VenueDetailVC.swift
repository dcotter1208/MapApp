//
//  VenueDetailVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class VenueDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venuePhotosCollectionView: UICollectionView!
    @IBOutlet weak var starRatingButton: UIButton!
    
    var venuePhotos = [1, 2, 3, 4, 5, 6, 7] // Will be UIImage array
    var userPhotos = [1, 2, 3, 4, 5, 6, 7] // Will be UIImage array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func starRatingPressed(_ sender: AnyObject) {
        if starRatingButton.imageView?.image == UIImage(named: "star_outlined") {
            starRatingButton.imageView?.image = UIImage(named: "star_filled")
        } else {
            starRatingButton.imageView?.image = UIImage(named: "star_outlined")
        }
        
    }
    
    
}
