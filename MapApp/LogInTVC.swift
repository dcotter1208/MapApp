//
//  LogInTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class LogInTVC: UITableViewController {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logIn(sender: AnyObject) {
        if let email = emailTF.text, password = passwordTF.text {
            FirebaseOperation().loginWithEmailAndPassword(email, password: password) {
                (error) in
                guard error == nil else {
                    print(error)
                    return
                }
            }
        }

    }

    @IBAction func continueAnonymously(sender: AnyObject) {
        print("anonymous")
    }
}
