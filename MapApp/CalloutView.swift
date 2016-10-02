//
//  CalloutView.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/1/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class CalloutView: UIView {
    @IBOutlet var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("Callout", owner: self, options: nil)
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
