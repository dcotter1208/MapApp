//
//  BotSearchResultCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/11/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import UIKit

class BotSearchResultCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var responseCollectionView: UICollectionView!

    //Will change this to hold actual venues for collection view datasource
    let venues = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Assigns the collectionview's delegate and datasource when the cell awakes.
        responseCollectionView.delegate = self
        responseCollectionView.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        Bot().handleMessage(message: message)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let responseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as! BotResponseResultCollectionViewCell
        
        return responseCell
    }
    
    
    //USE PREPAREFORREUSE** //USE PREPAREFORREUSE** //USE PREPAREFORREUSE** //USE PREPAREFORREUSE**//USE PREPAREFORREUSE**//USE PREPAREFORREUSE** //USE PREPAREFORREUSE** //USE PREPAREFORREUSE** //USE PREPAREFORREUSE**
    
    

}
