//
//  ChatMediaMessageTVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/12/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class ChatMediaMessageTVC: UITableViewController {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func sendMediaMessagePressed(_ sender: Any) {
        
    }

    @IBAction func cancelMessagePressed(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

}
