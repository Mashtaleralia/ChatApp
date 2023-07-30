//
//  RecipientProfileViewController.swift
//  ChatApp
//
//  Created by Admin on 24.07.2023.
//

import UIKit
import SDWebImage
import MessageKit



class RecipientProfileViewController: UIViewController {

    private var recipientName: String
    private var recipientPhotoUrl: URL?
    let conversationId: String?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        createProfileHeader()
        
    }
    
    init(recipientName: String, recipientPhotoUrl: URL?, conversationId: String? ) {
        self.recipientName = recipientName
        self.recipientPhotoUrl = recipientPhotoUrl
        self.conversationId = conversationId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    
    private func createProfileHeader() {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        let imageSize = view.width / 3
        let userImageView = UIImageView(frame: CGRect(x: (view.width - imageSize)/2, y: 100, width: imageSize, height: imageSize))
        userImageView.layer.cornerRadius = imageSize / 2
        userImageView.contentMode = .scaleAspectFill
        userImageView.backgroundColor = .red
        userImageView.layer.masksToBounds = true
        let userNameLabel = UILabel()
        userNameLabel.font = UIFont.systemFont(ofSize: 25)
        userNameLabel.tintColor = .black
        view.addSubview(headerView)
        headerView.addSubview(userImageView)
        headerView.addSubview(userNameLabel)
        
       
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 0).isActive = true
        headerView.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant:500).isActive = true
        headerView.topAnchor.constraint(equalTo:view.topAnchor, constant: 0).isActive = true
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
 
        userNameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 15.0).isActive = true
        userImageView.sd_setImage(with: recipientPhotoUrl, completed: nil)
        userNameLabel.text = recipientName
        
//        view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        let icons = ["phone.fill", "video.fill", "bell.fill", "magnifyingglass", "ellipsis"]
        let callButton = UIButton()
        let videoButton = UIButton()
        let muteButton = UIButton()
        let searchButton = UIButton()
        let moreButton = UIButton()
        let buttons = [callButton, videoButton, muteButton, searchButton, moreButton]
        var prevView = headerView
        for i in 0 ..< 5 {
            
            buttons[i].backgroundColor = .secondarySystemFill
            buttons[i].layer.cornerRadius = 10
            headerView.addSubview(buttons[i])
            buttons[i].translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(systemName: icons[i])
            buttons[i].setImage(image, for: .normal)
            
            buttons[i].topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 15).isActive = true
            if i == 0 {
                buttons[i].leadingAnchor.constraint(equalTo: prevView.leadingAnchor, constant: 15).isActive = true
            } else {
                buttons[i].leadingAnchor.constraint(equalTo: prevView.trailingAnchor, constant: 15).isActive = true
            }
            let dimension = (view.width - 15*6) / 5
            buttons[i].heightAnchor.constraint(equalToConstant: dimension).isActive = true
            buttons[i].widthAnchor.constraint(equalToConstant: dimension).isActive = true
            prevView = buttons[i]
           // buttons[i].addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
            switch i {
            case 0:
                buttons[i].addTarget(self, action: #selector(didTapPhoneButton), for: .touchUpInside)
            case 1:
                buttons[i].addTarget(self, action: #selector(didTapVideoButton), for: .touchUpInside)
            case 2:
                buttons[i].addTarget(self, action: #selector(didTapMuteButton), for: .touchUpInside)
            case 3:
                buttons[i].addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
            case 4:
                buttons[i].addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
            default:
                break
            }
        }
        
    }
    
    @objc private func didTapSearchButton() {
        let vc = SearchMessagesViewController(conversationId: conversationId)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
       
       
    }
    @objc private func didTapPhoneButton() {
      
       
       
    }
    @objc private func didTapVideoButton() {
       
       
       
    }
    @objc private func didTapMuteButton() {
       
       
       
    }
    @objc private func didTapMoreButton() {
    
       
       
    }
    
    
    

}
