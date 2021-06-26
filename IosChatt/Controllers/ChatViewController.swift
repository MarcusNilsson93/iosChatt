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

/*final class ChatViewController: MessagesViewController {
  
  private var isSendingPhoto = false {
    didSet {
      DispatchQueue.main.async {
        self.messageInputBar.leftStackViewItems.forEach { item in
          item.isEnabled = !self.isSendingPhoto
        }
      }
    }
  }
  
  private let db = Firestore.firestore()
  private var reference: CollectionReference?
  private let storage = Storage.storage().reference()

  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  
  private let user: User
  private let channel: Channel
  
  deinit {
    messageListener?.remove()
  }

  init(user: User, channel: Channel) {
    self.user = user
    self.channel = channel
    super.init(nibName: nil, bundle: nil)
    
    title = channel.name
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      return
    }

    reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
    
    messageListener = reference?.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .primary
    messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    let cameraItem = InputBarButtonItem(type: .system) // 1
    cameraItem.tintColor = .primary
    cameraItem.image = #imageLiteral(resourceName: "camera")
    cameraItem.addTarget(
      self,
      action: #selector(cameraButtonPressed), // 2
      for: .primaryActionTriggered
    )
    cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
    
    messageInputBar.leftStackView.alignment = .center
    messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
    messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false) // 3
  }
  
  // MARK: - Actions
  
  @objc private func cameraButtonPressed() {
    let picker = UIImagePickerController()
    picker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }
    
    present(picker, animated: true, completion: nil)
  }
  
  // MARK: - Helpers
  
  private func save(_ message: Message) {
    reference?.addDocument(data: message.representation) { error in
      if let e = error {
        print("Error sending message: \(e.localizedDescription)")
        return
      }
      
      self.messagesCollectionView.scrollToBottom()
    }
  }
  
  private func insertNewMessage(_ message: Message) {
    guard !messages.contains(message) else {
      return
    }
    
    messages.append(message)
    messages.sort()
    
    let isLatestMessage = messages.index(of: message) == (messages.count - 1)
    let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
    
    messagesCollectionView.reloadData()
    
    if shouldScrollToBottom {
      DispatchQueue.main.async {
        self.messagesCollectionView.scrollToLastItem(animated: true)
      }
    }
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    guard var message = Message(document: change.document) else {
      return
    }
    
    switch change.type {
    case .added:
      if let url = message.downloadURL {
        downloadImage(at: url) { [weak self] image in
          guard let `self` = self else {
            return
          }
          guard let image = image else {
            return
          }
          
          message.image = image
          self.insertNewMessage(message)
        }
      } else {
        insertNewMessage(message)
      }
      
    default:
      break
    }
  }
  
  private func uploadImage(_ image: UIImage, to channel: Channel, completion: @escaping (URL?) -> Void) {
    guard let channelID = channel.id else {
      completion(nil)
      return
    }
    
    guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
      completion(nil)
      return
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
    storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
      completion(meta?.downloadURL())
    }
  }

  private func sendPhoto(_ image: UIImage) {
    isSendingPhoto = true
    
    uploadImage(image, to: channel) { [weak self] url in
      guard let `self` = self else {
        return
      }
      self.isSendingPhoto = false
      
      guard let url = url else {
        return
      }
      
      var message = Message(user: self.user, image: image)
      message.downloadURL = url
      
      self.save(message)
      self.messagesCollectionView.scrollToBottom()
    }
  }
  
  private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
    let ref = Storage.storage().reference(forURL: url.absoluteString)
    let megaByte = Int64(1 * 1024 * 1024)
    
    ref.getData(maxSize: megaByte) { data, error in
      guard let imageData = data else {
        completion(nil)
        return
      }
      
      completion(UIImage(data: imageData))
    }
  }
  
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .primary : .incomingMessage
  }
  
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
    return false
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
  
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
  
  func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return .zero
  }
  
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: 0, height: 8)
  }
  
  func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    
    return 0
  }
  
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
  
  func currentSender() -> SenderType {
    return Sender(id: user.uid, displayName: AppSettings.displayName)
  }
  
  func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ]
    )
  }
  
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
  
  func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
    let message = Message(user: user, content: text)

    save(message)
    inputBar.inputTextView.text = ""
  }
  
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if let asset = info[.phAsset] as? PHAsset { // 1
      let size = CGSize(width: 500, height: 500)
      PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
        guard let image = result else {
          return
        }
        
        self.sendPhoto(image)
      }
    } else if let image = info[.originalImage] as? UIImage { // 2
      sendPhoto(image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
}**/
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
    let currentUser = Sender(senderId: "self", displayName: "Marcus")
    let recivingUser = Sender(senderId: "other", displayName: "Johan Doe")
    var messages = [MessageType]()
//    let msg: String
//    let msgId: String
//    let time: Date
    
    
    private let user: User
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
        
        
        
        let docRef = db.collection("Conversations")
        docRef.addSnapshotListener { snapshot, error in
            if (error != nil) {
                print(error!)
            }else {
                guard let snap = snapshot else {return}
                for document in snap.documents {
                    let data = document.data()
                    print("Data\(data)")
                    let msg = data["message"] as? String ?? "Error getting message"
                    let msgId = data["messageId"] as? String ?? "0"
                    let timeStamp = data["sentDate"] as? Date ?? Date().addingTimeInterval(-86400)
                    //let myDate = NSDate(timeIntervalSince1970: timeStamp)
                    print(msg)
                    print(msgId)
                    print(timeStamp)
                    self.messages.append(Message(sender: self.currentUser, messageId: msgId, sentDate: timeStamp, kind: .text(msg)))
            }
        }
    }
        
        
    }
    
    @objc func buttonClicked(sender: UIButton){
        let message = messageInputBar.inputTextView.text!
        print(message)
        sendMessage(Message: message, To: user.uid, From: fireBaseUser?.uid)
        messageInputBar.inputTextView.text = ""
        
    }
    func sendMessage(Message: String, To: String, From: String?) {
        print(To)
        print(From!)
        let db = Firestore.firestore()
        db.collection("Conversations").addDocument(data: ["msg" : Message, "to" : To, "sentDate": Date(), "messageId": 20, "from":From!]) { (error) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            print("Success")
            
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
                        
        /*db.collection("Conversations").document().collection("messages").addSnapshotListener { (snap, err) in
                    if err != nil {
                        print((err?.localizedDescription)!)
                        return
                    }
                    for i in snap!.documentChanges {
                        print(i)
                        if i.type == .added {
                            
                            guard let name = i.document.get("name") as? String else { return }
                            guard let msg = i.document.get("msg") as? String else { return }
                            guard let image = i.document.get("image") as? Data else { return }
                             let id = i.document.documentID
                            
                            self.messages.append(Message(sender: self.currentUser, messageId: id, sentDate: Date().addingTimeInterval(200000), kind: .text(msg)))
                            
                        }
                    }
                    
                }**/
        
        db.collection("Conversations")
            .getDocuments { querySnapshot, err in
            if ((err) != nil) {
                print("Error getting documents: \(err!)")
            } else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    let data = document.data()
                    print("Data\(data)")
                    let msg = data["message"] as? String ?? "Error getting message"
                    let msgId = data["messageId"] as? String ?? "0"
                    let timeStamp = data["sentDate"] as? Date ?? Date().addingTimeInterval(-86400)
                    //let myDate = NSDate(timeIntervalSince1970: timeStamp)
                    print(msg)
                    print(msgId)
                    print(timeStamp)
                    self.messages.append(Message(sender: self.currentUser, messageId: msgId, sentDate: timeStamp, kind: .text(msg)))
                    

                    
                    //print("\(document.documentID) => \(document.data())")
                    //print(self.user.userName)
                    //print(self.user.uid)
                    
                    //self.messages.append(Message(sender: self.currentUser, messageId: msgId, sentDate: timeStamp?.dateValue(), kind: .text(msg)))
                }
            }
        }

            messages.append(Message(sender: currentUser,
                                    messageId: "1",
                                    sentDate: Date().addingTimeInterval(-86400),
                                    kind: .text("Hello World!")))
            messages.append(Message(sender: recivingUser,
                                    messageId: "2",
                                    sentDate: Date().addingTimeInterval(-76400),
                                    kind: .text("Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!Does it work? Yes it do!")))
            messages.append(Message(sender: currentUser,
                                    messageId: "3",
                                    sentDate: Date().addingTimeInterval(-66400),
                                    kind: .text("Are you having a stroke?")))
            messages.append(Message(sender: recivingUser,
                                        messageId: "4",
                                    sentDate: Date().addingTimeInterval(-56400),
                                    kind: .text("No Im just exided")))
            messages.append(Message(sender: currentUser,
                                    messageId: "5",
                                    sentDate: Date().addingTimeInterval(-46400),
                                    kind: .text("Oh okey..")))
            messages.append(Message(sender: recivingUser,
                                    messageId: "6",
                                    sentDate: Date().addingTimeInterval(-36400),
                                    kind: .text("Yeeah!")))
 
 
    }
    
    func addInfo(msg: String, user: String, image: Data) {
        let db = Firestore.firestore()
        
        db.collection("chat").addDocument(data: ["msg": msg, "name": user, "image": image]) { (err) in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            print("Success")
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
//// MARK: - MessageInputBarDelegate
//
//extension ChatViewController: InputBarAccessoryViewDelegate {
//
//    func messageInputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//    let message = Message(user: user, content: text)
//
//    save(message)
//    inputBar.inputTextView.text = ""
//  }
//
//}

