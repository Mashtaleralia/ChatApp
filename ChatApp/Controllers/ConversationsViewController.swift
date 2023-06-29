//
//  ViewController.swift
//  ChatApp
//
//  Created by Admin on 24.06.2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class ConversationsViewController: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        }
    
    
    private func validateAuth() {
        
        //let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if FirebaseAuth.Auth.auth().currentUser == nil || GIDSignIn.sharedInstance.currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }      
    }
}
