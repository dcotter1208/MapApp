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
    @IBOutlet var tableViewTapGesture: UITapGestureRecognizer!

    let textInputViewHeight:CGFloat = 44.0

    var messages = [Message]()
    var bottomConstraint: NSLayoutConstraint?
    var keyboardHeight: CGFloat?
    var textInputView: TextInputView?
    var selectTextView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpKeyboardNotification()
        setUpTextInputView()
        chatTableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textInputView?.messageTextView.resignFirstResponder()
    }
    
    func setUpTextInputView() {
        let textInputViewWidth = view.frame.size.width
        let textInputViewXPosition = view.frame.origin.x
        let textInputViewYPosition = view.frame.maxY - textInputViewHeight

        let viewRectSize = CGRect(x: textInputViewXPosition, y: textInputViewYPosition, width: textInputViewWidth, height: textInputViewHeight)
        textInputView = TextInputView(frame: viewRectSize)
        textInputView?.delegate = self
        textInputView?.messageTextView.becomeFirstResponder()
        self.view.addSubview(textInputView!)
    }
    
    func adjustTextInputViewPosition(isKeyboardVisible: Bool) {
        let yPosition:CGFloat
        switch isKeyboardVisible {
        case true:
            yPosition = (view.frame.maxY - keyboardHeight!) - (textInputView!.frame.size.height)
        case false:
            yPosition = self.view.frame.maxY - self.textInputViewHeight
        }
        DispatchQueue.main.async {
            self.textInputView?.frame.origin.y = yPosition
        }
    }

    func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
                adjustTextInputViewPosition(isKeyboardVisible: true)
            }
        }
    }
    
    func keyboardWillHideNotification() {
        adjustTextInputViewPosition(isKeyboardVisible: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: TextInputViewDelegage

    func addAttachment() {
        print("Attachment added")
    }
    
    func sendMessage() {
        print("Message Sent")
    }
    
    //MARK: TableView

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
