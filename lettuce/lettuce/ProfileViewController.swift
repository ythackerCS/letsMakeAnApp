//
//  ProfileViewController.swift
//  lettuce
//
//  Created by Alex Appel on 2/16/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBAction func onPressedSignOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("Error Signing Out. Please Try Again!")
        }
        
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
