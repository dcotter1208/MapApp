//
//  CalloutView.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/1/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

protocol CustomCalloutActionDelegate {
    func moreInfoButtonSelected(sender: AnyObject)
    func enterChatSelected(sender: AnyObject)
}

class CalloutView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var delegate: CustomCalloutActionDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("Callout", owner: self, options: nil)
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func moreInfoSelected(_ sender: AnyObject) {
        self.delegate?.moreInfoButtonSelected(sender: sender)
    }
    
    @IBAction func enterChatSelected(_ sender: AnyObject) {
        self.delegate?.enterChatSelected(sender: sender)
    }
    
    
}
