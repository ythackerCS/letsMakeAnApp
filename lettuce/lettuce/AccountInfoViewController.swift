//
//  AccountInfoViewController.swift
//  lettuce
//
//  Created by Yash Thacker on 3/4/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class AccountInfoViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let db = Firestore.firestore()
        
        usernameLabel.text = Auth.auth().currentUser?.displayName!
        
        db.collection("users").getDocuments{ (querySnapshot, err) in
            if let err = err{
                print("Error getting documents: \(err)")
            }else{
                for document in querySnapshot!.documents{
                    if document.get("id") as? String == Auth.auth().currentUser?.uid {
                        if let dob = document.get("dob") as? Timestamp {
                            let dobDate = dob.dateValue()
                            
                            //                        let formatter = DateFormatter()
                            //                        formatter.dateFormat = "MM/dd/yyyy"
                            //                        let dateLabel = formatter.string(from: date)
                            
                            let calendar = Calendar.current
                            
                            // Replace the hour (time) of both dates with 00:00
                            let date1 = calendar.startOfDay(for: dobDate)
                            
                            let components = calendar.dateComponents([.year], from: date1, to: Date())
                            
                            self.ageLabel.text = "Age: \(components.year!)"
                            print(self.ageLabel.text)
                        }
                        
                        if let gender = document.get("gender") as? String {
                            self.genderLabel.text = "Gender: \(gender)"
                        }
                        else {
                            self.genderLabel.text = ""
                        }
                        
                    }
                    else {
                        print("Error occurred")
                    }
                }
                
            }
            
        }
        
    }
    
    @IBAction func signOutBtn(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("Error Signing Out. Please Try Again!")
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
