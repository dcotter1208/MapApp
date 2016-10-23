//
//  ChatVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/22/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TextInputViewDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageInputViewBottomConstraint: NSLayoutConstraint!
    
    var messages = [Message]()
    var bottomConstraint: NSLayoutConstraint?
    var keyboardHeight: CGFloat?
    var textInputView: TextInputView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpKeyboardNotification()
        setUpTextInputView()
    }
    
    func setUpTextInputView() {
        let textInputViewHeight:CGFloat = 44.0
        let textInputViewWidth = view.frame.size.width
        let textInputViewXPosition = view.frame.origin.x
        let textInputViewYPosition = view.frame.maxY - textInputViewHeight

        let viewRectSize = CGRect(x: textInputViewXPosition, y: textInputViewYPosition, width: textInputViewWidth, height: textInputViewHeight)
        textInputView = TextInputView(frame: viewRectSize)
        textInputView?.delegate = self
        self.view.addSubview(textInputView!)
    }
    
    func adjustTextInputViewWhenKeyboardVisible() {
        let newYPosition = (view.frame.maxY - keyboardHeight!) - (textInputView!.frame.size.height)
        textInputView?.frame.origin.y = newYPosition
        view.setNeedsLayout()
    }

    func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
    }
    
    func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
                adjustTextInputViewWhenKeyboardVisible()
            }
        }
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
            defaultMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultMessageCell
        }
        let currentUserMessageCell = tableView.dequeueReusableCell(withIdentifier: "CurrentUserMessageCell", for: indexPath) as! CurrentUserMessageCell
        currentUserMessageCell.setCellViewAttributesWithMessage(message: message)
        return currentUserMessageCell
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
