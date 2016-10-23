//
//  ChatVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/22/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chatTableView: UITableView!
    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        guard message.user.userID == "12345" else {
            let defaultMessageCell = tableView.dequeueReusableCell(withIdentifier: "DefaultMessageCell", for: indexPath) as! DefaultMessageCell
            defaultMessageCell.setCellAttributesWithMessage(message: message)
            return defaultMessageCell
        }
        let currentUserMessageCell = tableView.dequeueReusableCell(withIdentifier: "CurrentUserMessageCell", for: indexPath) as! CurrentUserMessageCell
        currentUserMessageCell.setCellAttributesWithMessage(message: message)
        return currentUserMessageCell

    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
