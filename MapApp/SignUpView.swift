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
    
    @IBOutlet weak var createProfileButton: UIButton!
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
        setButtonTitle()
        
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Helper Methods
    fileprivate func setButtonTitle() {
        if CurrentUser.sharedInstance.userID != "" {
            createProfileButton.setTitle("Update Profile", for: .normal)
        } else {
            createProfileButton.setTitle("Create Profile", for: .normal)
        }
    }
    
    @IBAction func createProfilePressed(_ sender: Any) {
        self.delegate?.createProfile(sender: sender)
    }
    
    @IBAction func photoSelectedTapGesture(_ sender: Any) {
        self.delegate?.photoSelected(sender: sender)
    }
}
