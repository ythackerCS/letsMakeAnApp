//
//  GoingTableViewController.swift
//  lettuce
//
//  Created by Alex Appel on 3/29/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//


import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class GoingTableViewController: UITableViewController {
    
    @IBOutlet weak var theTableView: UITableView!
    //    var events:[QueryDocumentSnapshot] = []
    
    let db = Firestore.firestore()
    
    var event: DocumentSnapshot!
    var selectedItemIndex = 0
    //    var people: [String] = []
    
    var goingList: [QueryDocumentSnapshot] = []
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "goingPersonDetails") as? PersonCard {
            
            myCell.userNameLabel.text = self.goingList[indexPath.item].get("username") as? String
            
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
    
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    ////        initView()
    ////        reloadEvents()
    //        //        print("reloading events")
    ////        initView()
    //        //        reloadEvents()
    //        //        print("events reloaded, initializing view...")
    //
    //        //        print("view initialized")
    //    }
    //
    //
    //    override func viewDidAppear(_ animated: Bool) {
    //        initView()
    //
    //        reloadEvents()
    //
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        for userID in self.event.get("going") as! [String] {
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
                        self.goingList.append(document)
                        print(self.goingList)
                        
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
    
    
    
    @objc func rejectUser(button: UIButton) {
        let buttonTag = button.tag
        
        let docRef = db.collection("events").document(event.documentID)
        
        // Atomically remove user from the "requested" array field.
        docRef.updateData([
            "going": FieldValue.arrayRemove([goingList[buttonTag].get("id")!])
        ])
        
        goingList.remove(at: buttonTag)
        
        self.theTableView.reloadData()
        
        // TODO:
        // notify the user that they were rejected via a push notification
        
    }
    
    
//    func reloadEvents(){
//        let db = Firestore.firestore()
//
//        goingList.removeAll()
//
//        let eventID = self.event.documentID
//        print("eventID: \(eventID)")
//
//        let docRef = db.collection("events").document(eventID)
//
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                //                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                //                print("Document data: \(dataDescription)")
//
//                print(document.get("going") as! [String])
//                print(document.get("username") as! String)
//                print(document.get("asdf"))
//                print(document.get("name"))
//                print(document.get("description") as! String)
//
//                for userID in document.get("going") as! [String] {
//                    print("________")
//                    print(userID)
//                    print("__________")
//                    db.collection("users").whereField("id", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
//                        if let err = err {
//                            print("Error getting documents: \(err)")
//                        }
//                        else {
//                            for document in querySnapshot!.documents {
//                                //                        print(document.data())
//                                //                        print(document.get("username")!)
//                                self.goingList.append(document)
//                                //                        print(self.goingList)
//
//                            }
//                        }
//                        self.theTableView.reloadData()
//
//                    }
//
//                }
//
//            } else {
//                print("Document does not exist")
//            }
//        }
//
        
        
        
//    }
}
