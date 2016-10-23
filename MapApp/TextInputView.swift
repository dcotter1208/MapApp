//
//  textInputView.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/23/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

protocol TextInputViewDelegate {
    func sendMessage()
    func addAttachment()
    func dismissKeyboardOnSwipe()
}

class TextInputView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
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

    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        print(sender.direction)
        sender.direction = .down
        if sender.direction == .down {
            self.delegate?.dismissKeyboardOnSwipe()
        }
    }
    
    @IBAction func sendMessageSelected(_ sender: AnyObject) {
        self.delegate?.sendMessage()
    }
    
    @IBAction func attachmentSelected(_ sender: AnyObject) {
        self.delegate?.addAttachment()
    }
    
    
}
