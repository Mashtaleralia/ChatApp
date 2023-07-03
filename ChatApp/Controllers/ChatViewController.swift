//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Admin on 30.06.2023.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
struct Sender: SenderType {
    var photoURL: URL?
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: nil, senderId: "1", displayName: "Ivan Ivanov")

    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date() , kind: .text("Hi; )")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date() , kind: .text("Hi hi!!!;)")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date() , kind: .text("Hi hi hi !!!;)")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date() , kind: .text("Hi hi hi hi!!!;)")))
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        // Do any additional setup after loading the view.
    }
    

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
