//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Admin on 30.06.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

struct Message: MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
   public var photoURL: String
   public var senderId: String
   public var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
}

struct Location: LocationItem {
    
    var location: CLLocation
    
    var size: CGSize
    
}



class ChatViewController: MessagesViewController {
    
    public var isNewConversation = false
    private var conversationId: String?
    public let otherUserEmail: String
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    private var messages = [Message]()
    
    
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("seccessfully got messages")
                print(id)
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
                   
            case .failure(let error):
                print("failed to get messages \(error)")
            }
        })
    }
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: self.title ?? "Me")
    }
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBackground
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
  
        setupInputButton()
        
       
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addConstraint(NSLayoutConstraint(item: avatarImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
        avatarImageView.addConstraint(NSLayoutConstraint(item: avatarImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
       
        configureAvatar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarImageView)
        avatarImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openRecipientProfile))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        avatarImageView.addGestureRecognizer(gesture)
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        
    }
    @objc private func openRecipientProfile() {
        let vc = RecipientProfileViewController(recipientName: otherUserEmail, recipientPhotoUrl: otherUserPhotoURL, conversationId: conversationId)
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    private func configureAvatar() {
        if let otherUserPhotoUrl = self.otherUserPhotoURL {
            avatarImageView.sd_setImage(with: otherUserPhotoUrl, completed: nil)
        } else {
            let email = self.otherUserEmail
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            let path = "images/\(safeEmail)_profile_picture.png"
            StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                switch result {
                case .success(let url):
                    DispatchQueue.main.async {
                        self?.otherUserPhotoURL = url
                        self?.avatarImageView.sd_setImage(with: url, completed: nil)
                    }
                case .failure(let error):
                    print("error setting avatar image \(error)")
                }
            
            })
        }
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside{ [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left , animated: false)
    }
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { [weak self] selectedCoordinates in
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            print("long=\(longitude) | lat=\(latitude)")
            guard let strongSelf = self else {
                return
            }
            guard let messageId = strongSelf.createMassegeId(),
                  let conversationId = strongSelf.conversationId,
            let name = strongSelf.title,
                  let selfSender = strongSelf.selfSender  else {
                 return
            }
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .location(location))
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("sent photo message")
                } else {
                    print("failed to send photo message")
                }
            })
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where wwould you like to attach photo from", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where wwould you like to attach video from", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }

}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let messageId = createMassegeId(),
        let conversationId = conversationId,
        let name = self.title,
        let selfSender = selfSender  else {
             return
        }
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
             
            // upload image
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded message photo: \(urlString)")
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        if success {
                            print("sent photo message")
                        } else {
                            print("failed to send photo message")
                        }
                    })
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
            })
        } else if let videoUrl = info[.mediaURL] as? URL{
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            //upload video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded message video: \(urlString)")
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        if success {
                            print("sent photo message")
                        } else {
                            print("failed to send photo message")
                        }
                    })
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
            })
            
        }
        
        
        // send message
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMassegeId() else {
            return
        }
        
        print("Sending: \(text)")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        if isNewConversation {
            // create convo in database
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User",  firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("failed to send")
                }
            })
        }
        else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            //append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                } else {
                    print("failed to send")
                }
            })
        }
    }
    private func createMassegeId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = ChatViewController.dateFormatter.string(from: Date()).replacingOccurrences(of: ".", with: "")
        
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
        
        // date, otherUserEmail, senderEmail, randomInt
    }
}


extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let path = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        
        let message = messages[path.section]
        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            self.navigationController?.pushViewController(vc, animated: true)
        
        default:
            break
        }
    }
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("Self sender is nil, email should be cached")
       // return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            return .link
        }
        return .secondarySystemBackground
    }
 func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
     avatarView.isHidden = true
    
//        let sender = message.sender
//
//        if sender.senderId == selfSender?.senderId {
//            if let currentUserImageURL = self.senderPhotoURL {
//                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
//            } else {
//                // fetch url
//                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
//                    return
//                }
//
//                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//                let path = "images/\(safeEmail)_profile_picture.png"
//                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
//                    switch result {
//                    case .success(let url):
//                        self?.senderPhotoURL = url
//                        DispatchQueue.main.async {
//                            avatarView.sd_setImage(with: url, completed: nil)
//                        }
//                    case .failure(let error):
//                        print("\(error)")
//                    }
//                })
//            }
//        } else {
//            if let otherUserImageURL = self.otherUserPhotoURL {
//                avatarView.sd_setImage(with: otherUserImageURL, completed: nil)
//            } else {
//                let email = self.otherUserEmail
//
//                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//                let path = "images/\(safeEmail)_profile_picture.png"
//                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
//                    switch result {
//                    case .success(let url):
//                        self?.otherUserPhotoURL  = url
//                        DispatchQueue.main.async {
//                            avatarView.sd_setImage(with: url, completed: nil)
//                        }
//                    case .failure(let error):
//                        print("\(error)")
//                    }
//                })
//            }
//        }
        }
}
extension ChatViewController: MessageCellDelegate {
    func didTapImage (in cell: MessageCollectionViewCell) {
        guard let path = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        
        let message = messages[path.section]
        switch message.kind {
        case .photo(let media):
            guard let url = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: url)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}

