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
    //MARK: **IBOutlets**

    @IBOutlet weak var chatTableView: UITableView!
    
    //MARK: **Cell Identifiers**
    
    //Media Message Cell Identifiers
    let CurrentUserPortraitMediaMessageCellIdentifier = "CurrentUserPortraitMediaMessageCell"
    let DefaultPortraitMediaMessageCellIdentifier = "DefaultPortraitMediaMessageCell"
    let CurrentUserLandscapeMediaMessageCellIdentifier = "CurrentUserLandscapeMediaMessageCell"
    let DefaultLandscapeMediaMessageCellIdentifier = "DefaultLandscapeMediaMessageCell"
    let BotSearchResultCellIdentifier = "BotSearchResultCell"
    
    //Text Message Cell Identifiers
    let CurrentUserMessageCellIdentifier = "CurrentUserMessageCell"
    let DefaultMessageCellIdentifier = "DefaultMessageCell"

    //MARK: **Variables**
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
    let bot = Bot.createBotWithUserID(userID: CurrentUser.sharedInstance.userID)
        
    //MARK: **Lifecycle**
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 140
        setUpKeyboardNotification()
        setUpmessageToolbar()
        chatTableView.keyboardDismissMode = .onDrag
        adjustTableViewInsetWithKeyboardHiding()
        queryAllMessagesFromFirebaseForVenue(venueID: "123456789")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        messageToolbar?.messageTextView.resignFirstResponder()
        venueID = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: **Firebase Helper Methods**
    func queryAllMessagesFromFirebaseForVenue(venueID: String) {
        let venueMessageQuery = firebaseOp.firebaseDatabaseRef.ref.child("messages").queryOrdered(byChild: "locationID").queryEqual(toValue: venueID)
        firebaseOp.queryChildWithConstraints(venueMessageQuery, firebaseDataEventType: FIRDataEventType.childAdded, observeSingleEventType: false) { (snapshot) in
            let message = Message.createMessageWithFirebaseData(snapshot: snapshot)
            if let safeMessage = message {
                self.messages.append(safeMessage)
                self.chatTableView.reloadData()
                self.scrollToLastMessage()
            }
         }
    }

    //MARK: **Helper Methods**
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
    
    func isBotChat() -> Bool {
        guard venueID != nil else {
            return true
        }
        return false
    }

    //MARK: **Message Toolbar Helper Methods**
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
    
    //MARK: **UITextView Delegate**
    
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
    
    //MARK: **Keyboard Notifications**
    
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
    
    //MARK: **MessageToolbarDelegate**

    func addAttachment() {
        performSegue(withIdentifier: "MediaMessageSegue", sender: self)
    }
    
    func sendMessage() {
        let currentUserID = CurrentUser.sharedInstance.userID
        
        guard let messageToolbar = messageToolbar else { return }
        
        let message = ["text" : messageToolbar.messageTextView.text, "timestamp" : "11/05/16", "userID" : currentUserID, "locationID": "123456789", "messageType" : MessageType.userText.rawValue] as [String : Any]
        
        firebaseOp.setValueForChild(child: "messages", value: message)
        bot.handleMessage(messageText: messageToolbar.messageTextView.text)
        
        messageToolbar.messageTextView.text = ""
        adjustMessageViewHeightWithMessageSize()
        
    }

    //MARK: **TableView**

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isCurrentUser = messageIsFromCurrentUser(message: message)
        
        switch message.messageType {
            
            //USER TEXT CELL CREATION
        case .userText:
            if isCurrentUser {
                return createChatCell(withMessage: message, andCellIdentifier: CurrentUserMessageCellIdentifier, atIndexPath: indexPath)
            } else {
                return createChatCell(withMessage: message, andCellIdentifier: DefaultMessageCellIdentifier, atIndexPath: indexPath)
            }
            
            //USER MEDIA CELL CREATION
        case .userMedia:
            if isCurrentUser {
                if isMediaOrientationPortait(message: message)! {
                    return createChatCell(withMessage: message, andCellIdentifier: CurrentUserPortraitMediaMessageCellIdentifier, atIndexPath: indexPath)
                } else {
                    return createChatCell(withMessage: message, andCellIdentifier: CurrentUserLandscapeMediaMessageCellIdentifier, atIndexPath: indexPath)
                }
            } else {
                if isMediaOrientationPortait(message: message)! {
                return self.createChatCell(withMessage: message, andCellIdentifier: DefaultPortraitMediaMessageCellIdentifier, atIndexPath: indexPath)
                }
                return createChatCell(withMessage: message, andCellIdentifier: DefaultLandscapeMediaMessageCellIdentifier, atIndexPath: indexPath)
            }
            
            //BOT CELL CREATiON
        case .botTextResponse:
            return createChatCell(withMessage: message, andCellIdentifier: DefaultMessageCellIdentifier, atIndexPath: indexPath)
        
        case .botSearchResponse:
            return createChatCell(withMessage: message, andCellIdentifier: BotSearchResultCellIdentifier, atIndexPath: indexPath)
            
        }
        
    }

    func isMediaOrientationPortait(message: Message?) -> Bool? {
        guard let mediaOrientation = message?.mediaOrientation else { return nil }
        
        switch mediaOrientation{
        case .portrait:
            return true
        default:
            return false
        }
    }
    
    fileprivate func createChatCell(withMessage message: Message, andCellIdentifier cellIdentifier: String, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let tempCell = UITableViewCell()
        
        switch cellIdentifier {
            //Text Message Cells
        case DefaultMessageCellIdentifier:
            let defaultMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DefaultMessageCell
            defaultMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultMessageCell
            
        case CurrentUserMessageCellIdentifier:
            let currentUserMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CurrentUserMessageCell
            currentUserMessageCell.setCellViewAttributesWithMessage(message: message)
            return currentUserMessageCell
            
            //Media Message Cells
            //Portrait Orientation
        case CurrentUserPortraitMediaMessageCellIdentifier:
            let currentUserPortraitMediaMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CurrentUserPortraitMediaMessageCell
            currentUserPortraitMediaMessageCell.setCellViewAttributesWithMessage(message: message)
            return currentUserPortraitMediaMessageCell
            
        case DefaultPortraitMediaMessageCellIdentifier:
            let defaultPortraitMediaMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DefaultPortraitMediaMessageCell
            defaultPortraitMediaMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultPortraitMediaMessageCell
            
            //Landscape Orientation
        case CurrentUserLandscapeMediaMessageCellIdentifier:
            let currentUserLandscapeMediaMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CurrentUserLandscapeMediaMessageCell
            currentUserLandscapeMediaMessageCell.setCellViewAttributesWithMessage(message: message)
            return currentUserLandscapeMediaMessageCell
            
        case DefaultLandscapeMediaMessageCellIdentifier:
            let defaultLandscapeMediaMessageCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DefaultLandscapeMediaMessageCell
            defaultLandscapeMediaMessageCell.setCellViewAttributesWithMessage(message: message)
            return defaultLandscapeMediaMessageCell
            
            //Bot Search Result Cell
        case BotSearchResultCellIdentifier:
            let botSearchResultCell = chatTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BotSearchResultCell
            botSearchResultCell.setCellViewAttributesWithMessage(message: message)
            return botSearchResultCell
            
        default:
            return tempCell
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
            let chatMediaMessageVC = destionationNavController.childViewControllers.first as! ChatMediaMessageVC
            chatMediaMessageVC.venueID = venueID
        }
    }
    
    //MARK: **IBActions**

    @IBAction func backButtonPressed(_ sender: AnyObject) {
       _ = navigationController?.popViewController(animated: true)
    }

}
