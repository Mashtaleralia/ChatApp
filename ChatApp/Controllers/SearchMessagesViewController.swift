//
//  SearchMessagesViewController.swift
//  ChatApp
//
//  Created by Admin on 25.07.2023.
//

import UIKit
import MessageKit

class SearchMessagesViewController: MessagesViewController {
    
 
    private var conversationId: String?
    private var messages: [Message]?
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for messages"
        return searchBar
    }()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: self.title ?? "")
    }
    
    init(conversationId: String?) {
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
        fetchMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchMessages() {
        guard let conversationId = conversationId else {
            return
        }

        DatabaseManager.shared.getAllMessagesForConversation(with: conversationId, completion: {result in
            switch result {
            case .success(let messages):
                self.messages = messages
            case .failure(let error):
                print("Fetchong failed with error: \(error)")
            }
        })
    }

}

extension SearchMessagesViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let messages = messages else {
            return Message(sender: selfSender!, messageId: "", sentDate: Date(), kind: .text(""))
        }
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let messages = messages else {
            return 0
        }
        return messages.count
    }
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("email should be chached")
    }
    
}
