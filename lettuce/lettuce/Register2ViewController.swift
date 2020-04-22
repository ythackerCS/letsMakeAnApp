//
//  Register2ViewController.swift
//  lettuce
//
//  Created by Uki Malla on 3/18/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class Register2ViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!
    
    // Variables that will be passed from the preceding view controller
    var firstNameText:String?
    var lastNameText:String?
    var usernameText:String?
    var emailText:String?
    var universityName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordText.delegate = self
        self.confirmPasswordText.delegate = self
    }
    
    @IBAction func checkCredentials(_ sender: Any) {
        
        guard let password = passwordText.text else { return }
        guard let confirmPassword = confirmPasswordText.text else { return }
        
        // Add password
        if password == confirmPassword {
            registerUser()
        }
        else {
           // Alert user that passwords do not match
            print("passwords do not match")
        }
    }
    
    
    func registerUser() {
        
        guard let firstName = firstNameText else { return }
        guard let lastName = lastNameText else { return }
        guard let username = usernameText else { return }
        guard let email = emailText else { return }
        guard let password = passwordText.text else { return }
//        guard let university = universityName else { return }
        let date = dobPicker.date
        
        // Lettuce get this fella registered
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
//                print("User created!")
                
                let db = Firestore.firestore()
                
                // Add a new document with a generated ID
                var ref: DocumentReference? = nil
                ref = db.collection("users").addDocument(data: [
                    "id": (Auth.auth().currentUser?.uid)!,
                    "username": username,
                    "firstName": lastName,
                    "lastName": firstName,
                    "email": email,
                    "dob": date
//                    "university": university
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
                
                // Change user display name
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { (error) in
                    if error == nil {
//                        print("User display name changed!")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            }
            else {
                print(error ?? nil!)
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
