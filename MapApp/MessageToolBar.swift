//
//  MessageToolBar.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/23/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

protocol MessageToolBarDelegate {
    func sendMessage()
    func addAttachment()
}

class MessageToolBar: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var delegate: MessageToolBarDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("MessageToolBar", owner: self, options: nil)
        view.frame = self.bounds
        messageTextView.layer.cornerRadius = 5
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func sendMessageSelected(_ sender: AnyObject) {
        self.delegate?.sendMessage()
    }
    
    @IBAction func attachmentSelected(_ sender: AnyObject) {
        self.delegate?.addAttachment()
    }
    
    
}
