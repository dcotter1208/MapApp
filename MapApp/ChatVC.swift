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

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, MessageToolBarDelegate {
    @IBOutlet weak var chatTableView: UITableView!

    let messageToolBarHeight:CGFloat = 44.0
    var messages = [Message]()
    var keyboardHeight: CGFloat?
    var messageToolBar: MessageToolBar?
    var selectTextView = true
    var maxmessageToolBarHeight: CGFloat?
    let firebaseOp = FirebaseOperation()
    var venueID: String?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 140
        setUpKeyboardNotification()
        setUpmessageToolBar()
        chatTableView.keyboardDismissMode = .onDrag
        queryAllMessagesFromFirebaseForVenue(venueID: venueID!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        messageToolBar?.messageTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Firebase Helper Methods
    func queryAllMessagesFromFirebaseForVenue(venueID: String) {
        let venueMessageQuery = firebaseOp.firebaseDatabaseRef.ref.child("messages").queryOrdered(byChild: "locationID").queryEqual(toValue: venueID)
        firebaseOp.queryChildWithConstraints(venueMessageQuery, firebaseDataEventType: FIRDataEventType.childAdded, observeSingleEventType: false) { (snapshot) in
            let message = snapshot.value as! NSDictionary
            let chatMessage = Message(message: message["message"] as! String, timestamp: message["timestamp"] as! String, locationID: message["locationID"] as! String, userID: message["userID"] as! String)
            self.messages.append(chatMessage)
            self.chatTableView.reloadData()
            self.scrollToLastMessage()
         }
    }
    
    func addMessageToChatView() {
        
    }
    
    //MARK: Message Toolbar Helper Methods
    func setUpmessageToolBar() {
        maxmessageToolBarHeight = self.view.frame.height / 1.5
        let messageToolBarWidth = view.frame.size.width
        let messageToolBarXPosition = view.frame.origin.x
        let messageToolBarYPosition = view.frame.maxY - messageToolBarHeight
        let viewRectSize = CGRect(x: messageToolBarXPosition, y: messageToolBarYPosition, width: messageToolBarWidth, height: messageToolBarHeight)
        messageToolBar = MessageToolBar(frame: viewRectSize)
        messageToolBar?.delegate = self
        messageToolBar?.messageTextView.delegate = self;
        messageToolBar?.messageTextView.becomeFirstResponder()
        self.view.addSubview(messageToolBar!)
    }
    
    func adjustMessageViewHeightWithIncreasedMessageSize() {
        if let textView = messageToolBar?.messageTextView {
            
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
        
        //Get the Text View's Content Size
        let contentSize = messageToolBar!.messageTextView.sizeThatFits(messageToolBar!.messageTextView.bounds.size)
        
        //Get the text view's current frame (at this point it would have been increased or decreased)
        var newFrame = messageToolBar!.messageTextView.frame
        
        //Set the textView's newFrame's Height based on the contentSize's Height
        newFrame.size.height = contentSize.height
        
        //Set the textview's current frame to the newFrame
        messageToolBar?.messageTextView.frame = newFrame
    }
    
    func adjustmessageToolBarHeight(increaseHeight: Bool, height: CGFloat) {
        var newmessageToolBarHeight = CGFloat()
        if increaseHeight == true {
            newmessageToolBarHeight = messageToolBar!.frame.size.height + height
        } else {
            newmessageToolBarHeight = messageToolBar!.frame.size.height - height
        }
        self.messageToolBar?.frame.size.height = newmessageToolBarHeight
        let yPosition = (view.frame.maxY - keyboardHeight!) - (messageToolBar!.frame.size.height)
        self.messageToolBar?.frame.origin.y = yPosition
    }
    
    func isMaxHeightReached() -> Bool {
        if let messageToolBarHeight = messageToolBar?.frame.height, let KBHeight = keyboardHeight, let maxHeight = maxmessageToolBarHeight {
            if messageToolBarHeight + KBHeight < maxHeight {
                return false
            }
        }
        return true
    }
    
    //MARK: UITextView Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        adjustMessageViewHeightWithIncreasedMessageSize()
    }
    
    func adjustmessageToolBarPosition(isKeyboardVisible: Bool) {
        let yPosition:CGFloat
        switch isKeyboardVisible {
        case true:
            yPosition = (view.frame.maxY - keyboardHeight!) - (messageToolBar!.frame.size.height)
        case false:
            yPosition = self.view.frame.maxY - messageToolBar!.frame.size.height
        }
        DispatchQueue.main.async {
            self.messageToolBar?.frame.origin.y = yPosition
        }
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
                adjustmessageToolBarPosition(isKeyboardVisible: true)
            }
        }
    }
    
    func keyboardWillHideNotification() {
        adjustmessageToolBarPosition(isKeyboardVisible: false)
    }
    
    //MARK: MessageToolBarDelegate

    func addAttachment() {
        print("Attachment added")
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
    
        let message = Message(message: messageToolBar!.messageTextView.text, timestamp: "11/05/16", locationID: venueID!,userID: currentUserID)
        firebaseOp.setValueForChild(child: "messages", value: ["message" : message.message, "timestamp" : message.timestamp, "locationID" : message.locationID, "userID" : message.userID])
        }
    
    //MARK: TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        guard message.userID == CurrentUser.sharedInstance.userID else {
            let defaultMessageCell = tableView.dequeueReusableCell(withIdentifier: "DefaultMessageCell", for: indexPath) as! DefaultMessageCell
            defaultMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultMessageCell
        }
        let currentUserMessageCell = tableView.dequeueReusableCell(withIdentifier: "CurrentUserMessageCell", for: indexPath) as! CurrentUserMessageCell
        currentUserMessageCell.setCellViewAttributesWithMessage(message: message)
        return currentUserMessageCell
    }

    func scrollToLastMessage() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
