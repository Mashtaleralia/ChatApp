//
//  SearchMessagesViewController.swift
//  ChatApp
//
//  Created by Admin on 25.07.2023.
//

import UIKit
import MessageKit
import SDWebImage

struct SearchedMessages: MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    var index: Int
    
}

class SearchMessagesViewController: MessagesViewController {
    
 
    private var conversationId: String?
    private var messages: [Message]?
    private var searchedMessages: [Message]? {
        didSet {
            messagesCollectionView.reloadData()
        }
    }
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for messages"
        return searchBar
    }()
    
    private var messageIndex = 0
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
        searchBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        configureToolBar()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        searchBar.becomeFirstResponder()
       
       
    }
    
    private func configureToolBar() {
        // Изменить цвет кнопок
        navigationController?.toolbar.tintColor = .black
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()

        navigationController?.toolbar.standardAppearance = appearance
        navigationController?.toolbar.scrollEdgeAppearance = appearance

        var buttons = [UIBarButtonItem]()

        buttons.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
                
        buttons.append(UIBarButtonItem(image: UIImage(systemName: "backward"), style: .plain, target: self, action: #selector(scrollDownToSearchMessage)))

        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
                
        buttons.append(UIBarButtonItem(image: UIImage(systemName: "forward"), style: .plain, target: self, action: #selector(scrollToSearchedMessage)))

        // Добавляем кнопки и отступы
        self.toolbarItems = buttons

        // Показать toolBar
        navigationController?.setToolbarHidden(false, animated: true)

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
    
    @objc private func scrollDownToSearchMessage() {
        guard let searchedMessages = searchedMessages, !searchedMessages.isEmpty,(0...searchedMessages.count - 1).contains(messageIndex), let index = messages?.firstIndex(of: searchedMessages[messageIndex]) else {
            return
        }
        messageIndex -= 1

        self.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: index), at: .centeredVertically, animated: true)
    }
    
    @objc private func scrollToSearchedMessage() {
       
        print(searchedMessages)
        guard let searchedMessages = searchedMessages, !searchedMessages.isEmpty,(0...searchedMessages.count - 1).contains(messageIndex), let index = messages?.firstIndex(of: searchedMessages[messageIndex]) else {
            return
        }
        messageIndex += 1

        self.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: index), at: .centeredVertically, animated: true)
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
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if let message = message as? Message, let searchedMessages = searchedMessages, searchedMessages.contains(message) {
            return UIColor.orange
        }
        let sender = message.sender
        if sender.senderId != selfSender?.senderId {
            return .darkText
        }
        return .white
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let url = media.url else {
                return
            }
            imageView.sd_setImage(with: url, completed: nil)
        default:
            break
        
        }
        
    }
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("email should be chached")
    }
    
}

extension SearchMessagesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        search(text)
        messageIndex = 0
        
        scrollToSearchedMessage()
        
    }
    private func search(_ query: String) {
        var filteredMessages = messages?.filter {
             switch $0.kind {
             case .text(let text):
                 return text.contains(query) || text.contains(query.lowercased())
             default:
                 break
             }
            return false
        }
        
        self.searchedMessages = filteredMessages
    }
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    
}
