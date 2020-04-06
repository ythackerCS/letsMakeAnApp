//
//  RequestedViewController.swift
//  lettuce
//
//  Created by Alex Appel on 3/28/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class RequestedViewController: UITableViewController {
    
    @IBOutlet weak var theTableView: UITableView!
//    var events:[QueryDocumentSnapshot] = []
    
    let db = Firestore.firestore()
    
    var event: DocumentSnapshot!
    var selectedItemIndex = 0
//    var people: [String] = []
    
    var requestedList: [QueryDocumentSnapshot] = []
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestedList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "requestedPersonDetails") as? PersonCard {
            
            myCell.userNameLabel.text = requestedList[indexPath.item].get("username") as? String
            
            myCell.acceptBtn.addTarget(self, action: #selector(acceptUser(button:)), for: .touchUpInside)
            myCell.acceptBtn.tag = indexPath.row
            
            myCell.rejectBtn.addTarget(self, action: #selector(rejectUser(button:)), for: .touchUpInside)
            myCell.rejectBtn.tag = indexPath.row
            
            return myCell
        }
        else {
//            print("Couldn't convert to event card")
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "myCell")
        
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        selectedItemIndex = indexPath.item
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        for userID in self.event.get("requested") as! [String] {
            print("________")
            print(userID)
            print("__________")
            db.collection("users").whereField("id", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        print(document.data())
                        print(document.get("username")!)
                        self.requestedList.append(document)
                        print(self.requestedList)
                        
                    }
                }
                self.theTableView.reloadData()
                
            }
            
        }
        
        
//        requestedList = self.event.get("requested") as! [String]
        
        initView()
//        loadEvents()
//        print(events.count)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        events.removeAll()
//        loadEvents()
    }
    
    
    @objc func acceptUser(button: UIButton) {
        
        let buttonTag = button.tag
        
        let docRef = db.collection("events").document(event.documentID)

        // Atomically add new user to the "going" array field.
        docRef.updateData([
            "going": FieldValue.arrayUnion([requestedList[buttonTag].get("id")!])
        ])

        // Atomically remove user from the "requested" array field.
        docRef.updateData([
            "requested": FieldValue.arrayRemove([requestedList[buttonTag].get("id")!])
        ])
        
        requestedList.remove(at: buttonTag)
        print(requestedList)
        
        self.theTableView.reloadData()
        
        // TODO:
            // notify the user that they were accepted via a push notification

    }
    
    @objc func rejectUser(button: UIButton) {
        let buttonTag = button.tag
        
        let docRef = db.collection("events").document(event.documentID)

        // Atomically remove user from the "requested" array field.
        docRef.updateData([
            "requested": FieldValue.arrayRemove([requestedList[buttonTag].get("id")!])
        ])
        
        requestedList.remove(at: buttonTag)
        
        self.theTableView.reloadData()
        
        // TODO:
            // notify the user that they were rejected via a push notification

    }
    
    
//    func loadEvents(){
//        let db = Firestore.firestore()
//
//        let currentUser = (Auth.auth().currentUser)!
//
//
//    }
}
