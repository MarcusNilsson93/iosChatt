//
//  ChatViewController.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-06-03.
//

import UIKit
import Photos
import Firebase
import MessageKit
import FirebaseFirestore
import InputBarAccessoryView


struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    private var fireBaseUser = Firebase.Auth.auth().currentUser
    private var user: User
    let currentUser = Sender(senderId: "self", displayName: "Marcus")
    let recivingUser = Sender(senderId: "other", displayName: "other user")
    var messages = [MessageType]()
    
    
    let db = Firestore.firestore()
    
    
    init(user:User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self as? InputBarAccessoryViewDelegate
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .yellow
        messageInputBar.sendButton.setTitleColor(.purple, for: .normal)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        
        let button = messageInputBar.sendButton
        button.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: .touchUpInside)
        user.userName = fireBaseUser?.displayName ?? "Current User"
        user.uid = fireBaseUser?.uid ?? "0"
        print(user.uid)
        print(user.userName)

    }

    @objc func buttonClicked(sender: UIButton){
        let message = messageInputBar.inputTextView.text!
        print(message)
        sendMessage(Message: message, To: user.uid, From: fireBaseUser?.uid)
        messageInputBar.inputTextView.text = ""
    }
    
    func sendMessage(Message: String, To: String, From: String?) {
        
        let db = Firestore.firestore()
        db.collection("Conversations").addDocument(data: ["msg" : Message, "to" : To, "sentDate": Date(), "messageId": UUID().uuidString, "from":From!]) { (error) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            print("Success")
            self.messagesCollectionView.scrollToLastItem()
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        let docRef = db.collection("Conversations").order(by: "sentDate")
        docRef.addSnapshotListener { snapshot, error in
            if (error != nil) {
                print(error!)
            }else {
                guard let snap = snapshot else {return}
                
                self.messages.removeAll()
                for document in snap.documents {
                    
                    let data = document.data()
                    print(document)
                    print("Data\(data)")

                    let msg = data["msg"] as? String ?? "Error getting a message"
                    let msgId = data["messageId"] as? String ?? "0"
                    let timeStamp = data["sentDate"] as? Date ?? Date()
                    let to = data["to"] as? String ?? ""
                    
                    if to == self.user.uid {
                        self.messages.append(Message(sender: self.currentUser, messageId: msgId, sentDate: timeStamp, kind: .text(msg)) as MessageType)
                    } else {
                        self.messages.append(Message(sender: self.recivingUser, messageId: msgId, sentDate: timeStamp, kind: .text(msg)) as MessageType)
                    }

            }
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
        }
    }

    }

    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

