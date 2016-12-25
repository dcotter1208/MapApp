//
//  SignUpView.swift
//  MapApp
//
//  Created by Donovan Cotter on 12/23/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

protocol SignUpViewDelegate {
    func createProfile(sender: Any)
    func photoSelected(sender: Any)
}

class SignUpView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!

    fileprivate var profileImageChanged: Bool?
    fileprivate var profileImage = UIImage()
    
    var delegate: SignUpViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("SignUpView", owner: self, options: nil)
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Helper Methods
    fileprivate func removeWhiteSpace(_ string:String?, removeAllWhiteSpace:Bool) -> String {
        guard let string = string else {return "nil"}
        guard removeAllWhiteSpace == false else {
            let newString = string.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "")
            return newString
        }
        let newString = string.trimmingCharacters(in: CharacterSet.whitespaces)
        return newString
    }
    
    @IBAction func createProfilePressed(_ sender: Any) {
        self.delegate?.createProfile(sender: sender)
    }
    
    @IBAction func photoSelectedTapGesture(_ sender: Any) {
        self.delegate?.photoSelected(sender: sender)
    }
}
