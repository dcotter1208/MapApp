//
//  ChatVC.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/22/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import AlamofireImage
import Alamofire

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, MessageToolbarDelegate {
    @IBOutlet weak var chatTableView: UITableView!

    let messageToolBarHeight:CGFloat = 44.0
    var messages = [Message]()
    var keyboardHeight: CGFloat?
    var messageToolbar: MessageToolbar?
    var selectTextView = true
    var maxmessageToolBarHeight: CGFloat?
    let firebaseOp = FirebaseOperation()
    var keyboardAnimationDuration = Double()
    var venueID: String?
    var imageForMessage: UIImage?
        
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 140
        setUpKeyboardNotification()
        setUpmessageToolbar()
        chatTableView.keyboardDismissMode = .onDrag
        adjustTableViewInsetWithKeyboardHiding()
        if let venueID = venueID {
            queryAllMessagesFromFirebaseForVenue(venueID: venueID)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        messageToolbar?.messageTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Firebase Helper Methods
    func queryAllMessagesFromFirebaseForVenue(venueID: String) {
        let venueMessageQuery = firebaseOp.firebaseDatabaseRef.ref.child("messages").queryOrdered(byChild: "locationID").queryEqual(toValue: venueID)
        firebaseOp.queryChildWithConstraints(venueMessageQuery, firebaseDataEventType: FIRDataEventType.childAdded, observeSingleEventType: false) { (snapshot) in
            let message = Message.createMessageWithFirebaseData(snapshot: snapshot)
            self.messages.append(message)
            self.chatTableView.reloadData()
            self.scrollToLastMessage()
         }
    }

    //MARK: Helper Methods:
    func adjustTableViewInsetWithKeyboardShowing() {
        UIView.animate(withDuration: 0.25, animations: {
            if let keyboardHeight = self.keyboardHeight, let messageToolbar = self.messageToolbar {
                self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + messageToolbar.frame.size.height, 0)
                self.chatTableView.scrollIndicatorInsets = self.chatTableView.contentInset
                self.scrollToLastMessage()
            }
        })
    }
    
    func adjustTableViewInsetWithKeyboardHiding() {
        if let messageToolbar = self.messageToolbar {
            chatTableView.contentInset = UIEdgeInsetsMake(0, 0, messageToolbar.frame.size.height, 0)
            self.chatTableView.scrollIndicatorInsets = self.chatTableView.contentInset
        }
    }

    //MARK: Message Toolbar Helper Methods
    func setUpmessageToolbar() {
        maxmessageToolBarHeight = self.view.frame.height / 1.5
        let messageToolBarWidth = view.frame.size.width
        let messageToolBarXPosition = view.frame.origin.x
        let messageToolBarYPosition = view.frame.maxY - messageToolBarHeight
        let viewRectSize = CGRect(x: messageToolBarXPosition, y: messageToolBarYPosition, width: messageToolBarWidth, height: messageToolBarHeight)
        messageToolbar = MessageToolbar(frame: viewRectSize)
        if let messageToolbar = messageToolbar {
            messageToolbar.delegate = self
            messageToolbar.messageTextView.delegate = self;
            self.view.addSubview(messageToolbar)
        }
    }
    
    func adjustMessageViewHeightWithMessageSize() {
        if let textView = messageToolbar?.messageTextView {
            switch isMaxHeightReached() {
            case false:
                let previousTextViewHeight = textView.frame.size.height
                setNewTextViewFrameSize()
                let currentTextViewHeight = textView.frame.size.height
                if  currentTextViewHeight > previousTextViewHeight {
                    let heightDifference = currentTextViewHeight - previousTextViewHeight
                    adjustmessageToolBarHeight(increaseHeight: true, height: heightDifference)
                } else if currentTextViewHeight < previousTextViewHeight {
                    let heightDifference = previousTextViewHeight - currentTextViewHeight
                    adjustmessageToolBarHeight(increaseHeight: false, height: heightDifference)
                }
            case true:
                let currentContentSizeHeight = textView.contentSize.height
                let currentTextViewHeight = textView.frame.size.height
                if currentContentSizeHeight < currentTextViewHeight {
                    let heightDifference = currentTextViewHeight - currentContentSizeHeight
                    adjustmessageToolBarHeight(increaseHeight: false, height: heightDifference)
                }
            }
        }
    }
    
    func setNewTextViewFrameSize() {
        guard let messageToolbar = messageToolbar else { return }
        
            //Get the Text View's Content Size
            let contentSize = messageToolbar.messageTextView.sizeThatFits(messageToolbar.messageTextView.bounds.size)
            
            //Get the text view's current frame (at this point it would have been increased or decreased)
            var newFrame = messageToolbar.messageTextView.frame
            
            //Set the textView's newFrame's Height based on the contentSize's Height
            newFrame.size.height = contentSize.height
            
            //Set the textview's current frame to the newFrame
            messageToolbar.messageTextView.frame = newFrame
    }
    
    func adjustmessageToolBarHeight(increaseHeight: Bool, height: CGFloat) {
        var newmessageToolBarHeight = CGFloat()
        guard let messageToolbar = messageToolbar, let keyboardHeight = keyboardHeight else { return }

        if increaseHeight == true {
            newmessageToolBarHeight = messageToolbar.frame.size.height + height
        } else {
            newmessageToolBarHeight = messageToolbar.frame.size.height - height
        }
        messageToolbar.frame.size.height = newmessageToolBarHeight
        let yPosition = (view.frame.maxY - keyboardHeight) - (messageToolbar.frame.size.height)
        messageToolbar.frame.origin.y = yPosition
    }
    
    func isMaxHeightReached() -> Bool {
        if let messageToolbarHeight = messageToolbar?.frame.height, let keyboardHeight = keyboardHeight, let maxHeight = maxmessageToolBarHeight {
            if messageToolbarHeight + keyboardHeight < maxHeight {
                return false
            }
        }
        return true
    }
    
    //MARK: UITextView Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        adjustMessageViewHeightWithMessageSize()
    }
    
    func adjustMessageToolBarPositionWithAnimation(duration: Double, isKeyboardVisible: Bool) {
        let yPosition:CGFloat
        
        guard let keyboardHeight = keyboardHeight, let messageToolbar = messageToolbar else { return }
        
        switch isKeyboardVisible {
        case true:
            yPosition = (view.frame.maxY - keyboardHeight) - (messageToolbar.frame.size.height)
        case false:
            yPosition = self.view.frame.maxY - messageToolbar.frame.size.height
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
            messageToolbar.frame.origin.y = yPosition
        
        }, completion: nil)
    }
    
    //MARK: Keyboard Notifications
    
    func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
                keyboardAnimationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
                adjustMessageToolBarPositionWithAnimation(duration: keyboardAnimationDuration, isKeyboardVisible: true)
                adjustTableViewInsetWithKeyboardShowing()
            }
        }
    }
    
    func keyboardWillHideNotification() {
        adjustMessageToolBarPositionWithAnimation(duration: keyboardAnimationDuration, isKeyboardVisible: false)
        adjustTableViewInsetWithKeyboardHiding()
    }
    
    //MARK: MessageToolbarDelegate

    func addAttachment() {
        performSegue(withIdentifier: "MediaMessageSegue", sender: self)
    }
    
    func sendMessage() {
        var currentUserID = ""
        if CurrentUser.sharedInstance.userID == "" {
            if let anonymousUserID = FIRAuth.auth()?.currentUser?.uid {
                currentUserID = anonymousUserID
            }
        } else {
            currentUserID = CurrentUser.sharedInstance.userID
        }
        
        guard let messageToolbar = messageToolbar else { return }

        firebaseOp.setValueForChild(child: "messages", value: ["text" : messageToolbar.messageTextView.text, "timestamp" : "11/05/16", "locationID" : venueID!, "userID" : currentUserID, "messageType" : MessageType.text.rawValue])
        messageToolbar.messageTextView.text = ""
        adjustMessageViewHeightWithMessageSize()
    }

    //MARK: TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isCurrentUser = messageIsFromCurrentUser(message: message)
        let defaultCell = UITableViewCell()
        
        switch message.messageType {
        case .text:
            if isCurrentUser {
                return createChatCell(withMessage: message, andCellIdentifier: "CurrentUserMessageCell", atIndexPath: indexPath)!
            } else {
                return createChatCell(withMessage: message, andCellIdentifier: "DefaultMessageCell", atIndexPath: indexPath)!
            }
        case .media:
            if isCurrentUser {
                return createChatCell(withMessage: message, andCellIdentifier: "CurrentUserMediaMessageCell", atIndexPath: indexPath)!
            } else {
                return createChatCell(withMessage: message, andCellIdentifier: "DefaultMediaMessageCell", atIndexPath: indexPath)!
            }
//        case .mediaText:
//            if isCurrentUser {
//                return createChatCell(withMessage: message, andCellIdentifier: "CurrentUserMediaTextMessageCell", atIndexPath: indexPath)!
//            } else {
//                return createChatCell(withMessage: message, andCellIdentifier: "DefaultMediaTextMessageCell", atIndexPath: indexPath)!
//            }
        default:
            return defaultCell
        }
        
        
//        
//        guard message.userID == CurrentUser.sharedInstance.userID else {
//            let defaultMessageCell = tableView.dequeueReusableCell(withIdentifier: "DefaultMessageCell", for: indexPath) as! DefaultMessageCell
//            defaultMessageCell.setCellViewAttributesWithMessage(message: message)
//            return defaultMessageCell
//        }
//        let currentUserMessageCell = tableView.dequeueReusableCell(withIdentifier: "CurrentUserMessageCell", for: indexPath) as! CurrentUserMessageCell
//        currentUserMessageCell.setCellViewAttributesWithMessage(message: message)
//        return currentUserMessageCell
    }
    
    fileprivate func createChatCell(withMessage message: Message, andCellIdentifier cellIdentifier: String, atIndexPath indexPath: IndexPath) -> UITableViewCell? {
        switch cellIdentifier {
        case "DefaultMessageCell":
            let defaultMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DefaultMessageCell
            defaultMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultMessageCell
        case "CurrentUserMessageCell":
            let currentUserMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CurrentUserMessageCell
            currentUserMessageCell.setCellViewAttributesWithMessage(message: message)
            return currentUserMessageCell
        case "CurrentUserMediaMessageCell":
            let currentUserMediaMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CurrentUserMediaMessageCell
            currentUserMediaMessageCell.setCellViewAttributesWithMessage(message: message)
            return currentUserMediaMessageCell
        case "DefaultMediaMessageCell":
            let defaultMediaMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DefaultMediaMessageCell
            defaultMediaMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultMediaMessageCell
        default:
            return nil
        }
    }
    
    fileprivate func messageIsFromCurrentUser(message: Message) -> Bool {
        return message.userID == CurrentUser.sharedInstance.userID
    }

    func scrollToLastMessage() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MediaMessageSegue" {
            let destionationNavController = segue.destination as! UINavigationController
            let chatMediaMessageTVC = destionationNavController.childViewControllers.first as! ChatMediaMessageTVC
            chatMediaMessageTVC.venueID = venueID
        }
    }
    
    //MARK: IBActions

    @IBAction func backButtonPressed(_ sender: AnyObject) {
       _ = navigationController?.popViewController(animated: true)
    }

}
