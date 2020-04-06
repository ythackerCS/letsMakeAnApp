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
    
    
    
    
    
    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     let chatVC = segue.destination as? ChatViewController
           
           if chatVC != nil{
            chatVC?.chatListStub = chatItemList[selectionIndex]
           }
        
        
     }
    
}
