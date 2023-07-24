//
//  RecipientProfileViewController.swift
//  ChatApp
//
//  Created by Admin on 24.07.2023.
//

import UIKit
import SDWebImage

class RecipientProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        createProfileHeader()
        
    }
    var recipientName: String
    var recipientPhotoUrl: URL?
    
    init(recipientName: String, recipientPhotoUrl: URL?) {
        self.recipientName = recipientName
        self.recipientPhotoUrl = recipientPhotoUrl
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
        headerView.addSubview(userImageView)
        headerView.addSubview(userNameLabel)
        view.addSubview(headerView)

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
        var prevView = headerView
        for i in 0 ..< 5 {
            let button = UIButton()
            button.backgroundColor = .secondarySystemFill
            button.layer.cornerRadius = 10
            headerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(systemName: icons[i])
            button.setImage(image, for: .normal)
            
            button.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 15).isActive = true
            if i == 0 {
                button.leadingAnchor.constraint(equalTo: prevView.leadingAnchor, constant: 15).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: prevView.trailingAnchor, constant: 15).isActive = true
            }
            let dimension = (view.width - 15*6) / 5
            button.heightAnchor.constraint(equalToConstant: dimension).isActive = true
            button.widthAnchor.constraint(equalToConstant: dimension).isActive = true
            prevView = button
            
        }
        
    }
    
    private func createActionButtons() {
      
    }
    
    
    

}
