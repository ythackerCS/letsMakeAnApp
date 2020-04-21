//
//  ChatListItem.swift
//  lettuce
//
//  Created by Uki Malla on 3/22/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatListItem{
    var chatTitle:String = ""
    var chatSubtitle:String = ""
    
    var uid:[String] = []
    
    var uidToUsername:[String:String] = [:]
    
    var documentID:String
    
    var documentSnapshot:DocumentSnapshot!
    var dcoumentReference:DocumentReference!
    var onCompletion:() -> Void
        
    
    private func _getUserNames(){
        
        let db = Firestore.firestore()
        
        // Getting username from uid using firestore
        for user in uid{
                db.collection("users").whereField("id", isEqualTo: user).getDocuments{
                    (snap, err) in
                    if let err = err{
                        print("Error getting documents: \(err)")
                    }else{
                        for document in snap!.documents {
                            if let username = document.get("username") as? String{
                                self.uidToUsername[user] = username
                            }
                        }
                        self._parseTitle()
                    }
            }

        }
    }
    
    
    private func _parseSubtitle(doc:QueryDocumentSnapshot){
        if let message = doc.get("message") as? String{
            chatSubtitle = message
        }
        self.onCompletion()
        
        
    }
    
    
    private func _parseTitle(){
        chatTitle = ""
        if let eventName = documentSnapshot.get("eventName") as? String{
            chatTitle += eventName
        }
        
        var chatPeople = ""
            
            for (uid, username) in uidToUsername{
                if(uid != Auth.auth().currentUser?.uid){
                       chatPeople += username + ", "
                }
           }
        if chatPeople == ""{
            chatPeople = "Only You"
        }else{
            if let i = chatPeople.lastIndex(of: ","){
                              chatPeople.remove(at: i)
              }
                          
          if let i = chatPeople.lastIndex(of: " "){
              chatPeople.remove(at: i)
          }
        }
        
              
        

        
        
        if chatTitle == ""{
            chatTitle = chatPeople
        }else{
            chatTitle += " (\(chatPeople))"
        }
        
        print("Set title to " +  chatTitle)
        self.onCompletion()

        

    }
    
    init(qDocumentSnapshot:QueryDocumentSnapshot, completion: @escaping () -> Void) {
        documentID = qDocumentSnapshot.documentID
        documentSnapshot = qDocumentSnapshot
        let db = Firestore.firestore()
        onCompletion = completion
        
        if let users = qDocumentSnapshot.get("users") as? [String]{
            self.uid = users
            self._getUserNames()

            
            // Getting the latest message
            db.collection("chats").document(qDocumentSnapshot.documentID).collection("chat").order(by: "timestamp", descending: true).limit(to: 1).getDocuments{
                (snap, err) in
                
                if let err = err{
                    print("Error getting documents: \(err)")
                }else{
                    // Setting the latest message as the subtitle
                    for document in snap!.documents {
                        self._parseSubtitle(doc: document)
                    }
                    completion()
                }
            }
        }
        
        
    }
    
    
    
    
    
}
