//
//  ChatListViewController.swift
//  lettuce
//
//  Created by Uki Malla on 3/22/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var chatItemList:[ChatListItem] = []
    var selectionIndex:Int = 0
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell:UITableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: "chatListCell")
        if (myCell == nil)
        {
            myCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                     reuseIdentifier: "chatListCell")
        }
        
        myCell?.textLabel?.text = chatItemList[indexPath.item].chatTitle
        print("subtitle \(chatItemList[indexPath.item].chatSubtitle)")
        myCell?.detailTextLabel?.text = chatItemList[indexPath.item].chatSubtitle
        
        return myCell!
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        selectionIndex = indexPath.item
        return true
    }
    
    
    @IBOutlet weak var theTableView: UITableView!
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
    }
    
    
    func fetchDataFromFB(){
        let db = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid{
            db.collection("chats").whereField("users",  arrayContains:uid).getDocuments{
                (querySnapshot, err) in
                if let err = err{
                    print("Error getting documents: \(err)")
                }else{
                    self.chatItemList.removeAll()
                    for document in querySnapshot!.documents {
                        let item = ChatListItem(qDocumentSnapshot: document, completion: self._onChatLoadComplete)
                        self.chatItemList.append(item)
                        
                    }
                    
                    
                }
                
                
            }
            
            
        }
        
        
        
    }
    
    
    
    func _onChatLoadComplete() -> Void{
        theTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addSelfToEvents()
        
        
        
        fetchDataFromFB()
        let db = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid{
            db.collection("chats").whereField("users", arrayContains: uid).addSnapshotListener{
                documentSnapshot, error in
                guard let _ = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                self.fetchDataFromFB()
            }
        }
    }
    
    func addSelfToChat(uid: String, chatID: String){
        let db = Firestore.firestore()
        db.collection("chats").document(chatID).updateData([
            "users" : FieldValue.arrayUnion([uid])
        ]){ err in
            if let err = err {
                print("Error adding document: \(err)")
                
            } else {
                print("Could add to chat: \(chatID)")
            }
        }
        
    }
    
    func createChat(uid: String, eventID: String, eventName: String?) -> DocumentReference?{
        var chatRef: DocumentReference? = nil
        let db = Firestore.firestore()
        var chat :[String:Any] = [
        "users": FieldValue.arrayUnion([uid]),
        "eventID": eventID
        ]
        
        if eventName != nil{
            chat["eventName"] = eventName
        }
        
        chatRef = db.collection("chats").addDocument(data: chat
        ) { err in
            if let err = err {
                print("Error adding document: \(err)")
                
            } else {
                print("Chat created with ID: \(chatRef!.documentID)")
            }
        }
        return chatRef
    }
    
    
    func addSelfToEvents(){
        let db = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid{
            db.collection("events").whereField("going", arrayContains: uid).getDocuments{
                doc, error in
                if let error = error{
                    print(error)
                }else{
                    for document in doc!.documents{
                        if let chatID = document.get("chat") as? String{
                            self.addSelfToChat(uid: uid, chatID: chatID)
                        }else{
                            // Creating a chat document
                            let eventName:String? = document.get("name") as? String
                            let chatID: DocumentReference? = self.createChat(uid: uid, eventID: document.documentID, eventName: eventName)
                            // Adding chatID to events document
                            if(chatID != nil){
                                db.collection("events").document(document.documentID).updateData(
                                    ["chat" : chatID!.documentID])
                            }
                        }
                    }
                }
            }
        }
        
    }
        
        
        
        
        
        
        
        
        // MARK: - Navigation
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let chatVC = segue.destination as? ChatViewController
            
            if chatVC != nil{
                chatVC?.chatListStub = chatItemList[selectionIndex]
            }
            
            
        }
        
}
