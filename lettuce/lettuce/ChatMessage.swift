//
//  ChatMessage.swift
//  lettuce
//
//  Created by Uki Malla on 3/22/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ChatMessage{
    
    var chatMessage:String = ""
    var uid:String = ""
    var username:String = ""
    var timestamp:Timestamp?
    
    var documentSnapshot:DocumentSnapshot!
    var dcoumentReference:DocumentReference!
    
    
    init(qDocSnap: QueryDocumentSnapshot, uidToUsername:[String:String]) {
        if let uid = qDocSnap.get("uid") as? String{
            self.uid = uid
            if let username = uidToUsername[uid]{
                self.username = username
            }
        }
        
        if let message = qDocSnap.get("message") as? String{
            self.chatMessage = message
        }
        
        if let timestamp = qDocSnap.get("timestamp") as? Timestamp{
            self.timestamp = timestamp
        }
        
    }
    
    
        
        
        
}
