//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Admin on 24.06.2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(googleLoginButton)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        passwordField.delegate = self
        emailField.delegate = self
        googleLoginButton.addTarget(self, action: #selector(didTapGoogleSignIn), for: .touchUpInside)
    }
    
    private let googleLoginButton = GIDSignInButton()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "message-logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width / 2
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 50, width: scrollView.width - 60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
        googleLoginButton.frame = CGRect(x: 30, y: loginButton.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc func didTapGoogleSignIn() {
               

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
          guard error == nil else {
            print("error loggin in via google account")
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            return
          }
            guard let profile = user.profile else {
                return
            }
            let email = profile.email
            let firstName = profile.name
            let lastName = profile.familyName
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            guard let firstName = profile.givenName, let lastName = profile.familyName else {
                return
            }
                DatabaseManager.shared.userExists(with: email) { exists in
                    if !exists {
                        let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                        DatabaseManager.shared.insertUser(with: chatUser, completion: {success in
                            if success {
                                if profile.hasImage {
                                    guard let url = profile.imageURL(withDimension: 200) else {
                                        return
                                    }
                                    URLSession.shared.dataTask(with: url, completionHandler: {data, _, _ in
                                        guard let data = data else {
                                            return
                                        }
                                        let fileName = chatUser.profilePictureFileName
                                            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                                switch result {
                                                case .success(let downloadUrl):
                                                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                                    print(downloadUrl)
                                                case .failure(let error):
                                                    print("storage manager error \(error)")
                                        
                                                }
                                            })
                                        
                                    }).resume()
                                }
                              

                            }
                        }
                            
                        )
                    }
                    
                }
            
            

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("failed to log in")
                    return
                }
                print("Successfully logged in via google")
            })
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
          // ...
        }
    }
     
    @objc func didTapLoginButton() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard error == nil, let result = authResult else {
                print("failed to log in with email: \(email)")
                return
            }
            let user = result.user
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getData(path: safeEmail, completion: { [weak self] result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any], let firstName = userData["first_name"] as? String, let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            UserDefaults.standard.set(email, forKey: "email")
            print(user)
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        // Firebase login
        
    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Oops!", message: "Please enter all information to log in", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
    
    @objc func didTapRegister() {
         let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    


}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
}
