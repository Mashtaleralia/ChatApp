//
//  ViewController.swift
//  ChatApp
//
//  Created by Admin on 24.06.2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setUpTableView()
        fetchConversations()
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private func validateAuth() {
        
        //let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if FirebaseAuth.Auth.auth().currentUser == nil  {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }      
    }
}

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController(with: "ahahah@gmail.com")
        vc.title = "Jenny Smith"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
