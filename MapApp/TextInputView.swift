//
//  textInputView.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/23/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

protocol TextInputViewDelegate {
    
}

class TextInputView: UIView {
    @IBOutlet var view: UIView!

    var delegate: TextInputViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("TextInputView", owner: self, options: nil)
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
