//
//  LoginViewController.swift
//  lettuce
//
//  Created by Alex Appel on 2/16/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//


import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createNewAccountButton: UIButton!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityView.startAnimating()
        
        Auth.auth().addStateDidChangeListener{(auth, user) in
            if Auth.auth().currentUser != nil{
                self.performSegue(withIdentifier: "toProfileScreen", sender: self)
            }else{
                self.activityView.stopAnimating()
            }
        }
        
        self.hideKeyboardWhenTappedAround()
        
        self.emailText.delegate = self
        self.passwordText.delegate = self
        
        loginButton.layer.cornerRadius = 15
        
        activityView.hidesWhenStopped = true
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        activityView.startAnimating()
        guard let email = emailText.text else { return }
        guard let password = passwordText.text else { return }

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil && user != nil {
                self.activityView.stopAnimating()
//                print("User signed in!")
                self.performSegue(withIdentifier: "toProfileScreen", sender: self)
            } else {
                self.activityView.stopAnimating()
//                print("Error signing in user: \(error!.localizedDescription)")
            }
        }
    }
    
}

