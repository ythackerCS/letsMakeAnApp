//
//  ChatViewController.swift
//  lettuce
//
//  Created by Uki Malla on 3/22/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var chatListStub:ChatListItem!
    var chatMessageList:[ChatMessage] = []
    let currentUser = Auth.auth().currentUser?.uid
    let CHAT_LIMIT = 25
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell:UITableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: "myCell")
        
        if (myCell == nil)
        {
            myCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                        reuseIdentifier: "myCell")
        }
        
        for item in myCell!.contentView.subviews{
            item.removeFromSuperview()
        }
        
        
       myCell?.contentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        if(chatMessageList[indexPath.item].uid == Auth.auth().currentUser?.uid){
            showOutgoingMessage(text: chatMessageList[indexPath.item].chatMessage, view: myCell!.contentView, myMessage: true)
        }
        else{
            showOutgoingMessage(text: chatMessageList[indexPath.item].chatMessage, view: myCell!.contentView, myMessage: false)
        }
        return myCell!
    }
    
    
    @IBOutlet weak var messageBox: UITextView!
    
    @IBOutlet weak var theTableView: UITableView!
    @IBOutlet weak var messageBoxHeight: NSLayoutConstraint!
    
    
    
    func initView(){
        theTableView.dataSource = self
        theTableView.delegate = self
        self.title = chatListStub.chatTitle
        
        let db = Firestore.firestore()
           if let _ = Auth.auth().currentUser?.uid{
               db.collection("chats").document(chatListStub.documentID).collection("chat").addSnapshotListener{
                       documentSnapshot, error in
                      guard let _ = documentSnapshot else {
                      print("Error fetching document: \(error!)")
                      return
                    }
                   
                   self.fetchDataFromDB()
               }
           }
        
        
    }
    
    
    func fetchDataFromDB(){
        let db = Firestore.firestore()
        // Get latest 10 message
        db.collection("chats").document(chatListStub.documentID).collection("chat").order(by: "timestamp", descending: true).limit(to: CHAT_LIMIT).getDocuments{
            (snap, err) in
            
            if let err = err{
                print("Error getting documents: \(err)")
            }else{
                self.chatMessageList.removeAll()
                // Setting the latest message as the subtitle
                for document in snap!.documents {
                    let msg = ChatMessage(qDocSnap: document, uidToUsername: self.chatListStub.uidToUsername)
                    self.chatMessageList.append(msg)
                    self.theTableView.reloadData()
                    self.scrollToBottom()
                }
                self.chatMessageList.reverse()
            }
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        fetchDataFromDB()
        theTableView.rowHeight = UITableView.automaticDimension
        messageBox.delegate = self
        messageBox.layer.cornerRadius = 10
        messageBox.layer.borderWidth = 1
        //inset padding; https://www.hackingwithswift.com/example-code/uikit/how-to-pad-a-uitextview-by-setting-its-text-container-inset
        messageBox.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // Do any additional setup after loading the view.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            onPressSend(textView)
            return false
        }
        return true
    }
    
    @objc func tapDone(sender: Any){
        print("pressed")
    }
    
    @IBAction func onPressSend(_ sender: Any) {
        if let message = messageBox.text{
            if message != ""{
                let db = Firestore.firestore()
                db.collection("chats").document(chatListStub.documentID).collection("chat").addDocument(data:[
                    "message" : message,
                    "uid": currentUser!,
                    "timestamp": FieldValue.serverTimestamp()
                ])
                fetchDataFromDB()
                messageBox.text = ""
            }
        }
    }
    
    
    
    
    
    //chat message design https://medium.com/@dimabauer/creating-a-chat-bubble-which-looks-like-a-chat-bubble-in-imessage-the-advanced-way-2d7497d600ba
    func showOutgoingMessage(text: String, view: UIView, myMessage: Bool){
        let label =  UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = text

        let constraintRect = CGSize(width: 0.66 * view.frame.width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: label.font!],
                                            context: nil)
        label.frame.size = CGSize(width: ceil(boundingBox.width),
                                  height: ceil(boundingBox.height))

        let bubbleSize = CGSize(width: label.frame.width + 28,
                                     height: label.frame.height + 20)

        let width = bubbleSize.width
        let height = bubbleSize.height

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: width - 22, y: height))
        bezierPath.addLine(to: CGPoint(x: 17, y: height))
        bezierPath.addCurve(to: CGPoint(x: 0, y: height - 17), controlPoint1: CGPoint(x: 7.61, y: height), controlPoint2: CGPoint(x: 0, y: height - 7.61))
        bezierPath.addLine(to: CGPoint(x: 0, y: 17))
        bezierPath.addCurve(to: CGPoint(x: 17, y: 0), controlPoint1: CGPoint(x: 0, y: 7.61), controlPoint2: CGPoint(x: 7.61, y: 0))
        bezierPath.addLine(to: CGPoint(x: width - 21, y: 0))
        bezierPath.addCurve(to: CGPoint(x: width - 4, y: 17), controlPoint1: CGPoint(x: width - 11.61, y: 0), controlPoint2: CGPoint(x: width - 4, y: 7.61))
        bezierPath.addLine(to: CGPoint(x: width - 4, y: height - 11))
        bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 4, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
        bezierPath.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
        bezierPath.addCurve(to: CGPoint(x: width - 11.04, y: height - 4.04), controlPoint1: CGPoint(x: width - 4.07, y: height + 0.43), controlPoint2: CGPoint(x: width - 8.16, y: height - 1.06))
        bezierPath.addCurve(to: CGPoint(x: width - 22, y: height), controlPoint1: CGPoint(x: width - 16, y: height), controlPoint2: CGPoint(x: width - 19, y: height))
        bezierPath.close()

        let outgoingMessageLayer = CAShapeLayer()
        outgoingMessageLayer.path = bezierPath.cgPath
        
        
        if(myMessage){        //https://stackoverflow.com/questions/49508639/how-do-i-flip-over-a-uibezierpath-or-cgpath-thats-animated-onto-the-cashapelayer?rq=1 how to transform
            outgoingMessageLayer.frame = CGRect(x: self.view.frame.width-width-5,
            y: view.frame.height/2 - height/2,
            width: width,
            height: height)
//            outgoingMessageLayer.fillColor = UIColor(red: 0.251, green: 0.8196, blue: 0.0627, alpha: 1.0).cgColor
            outgoingMessageLayer.fillColor = UIColor(red: 144/255, green: 206/255, blue: 158/255, alpha: 1.0).cgColor
            outgoingMessageLayer.transform = CATransform3DMakeScale(1, 1, 1)
        }
        else{
            outgoingMessageLayer.frame = CGRect(x: 5,
            y: view.frame.height/2 - height/2,
            width: width,
            height: height)
//            outgoingMessageLayer.fillColor = UIColor(red: 0.5686, green: 0.8196, blue: 0.4314, alpha: 1.0).cgColor
            outgoingMessageLayer.fillColor = UIColor.systemGray.cgColor
            outgoingMessageLayer.transform = CATransform3DMakeScale(-1, 1, 1)
        }
        view.layer.addSublayer(outgoingMessageLayer)
        outgoingMessageLayer.position.y = outgoingMessageLayer.frame.height/2 + 5
        label.clipsToBounds = false
        label.center = outgoingMessageLayer.position
        view.frame.size.height = outgoingMessageLayer.frame.height + 10
        view.addSubview(label)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(theTableView, cellForRowAt: indexPath)
        let height = cell.subviews[0].frame.size.height
        return height
    }
    
    
    //how to scroll to bottom: https://stackoverflow.com/questions/33705371/how-to-scroll-to-the-exact-end-of-the-uitableview
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.chatMessageList.count-1, section: 0)
        self.theTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func textViewDidChange(_ textView: UITextView){
        //get number of rows https://stackoverflow.com/questions/3585470/how-to-read-number-of-lines-in-uitextview
        messageBox.scrollRangeToVisible(NSMakeRange(messageBox.text.count-1,0))
        let rows = (messageBox.contentSize.height - messageBox.textContainerInset.top - messageBox.textContainerInset.bottom) / messageBox.font!.lineHeight
        if(rows>=2){
            //https://www.google.com/search?rlz=1C5CHFA_enUS865US865&sxsrf=ALeKk03r5gwcVfHwNZjbXxijjxpdPrLe4w%3A1585198369856&ei=ITV8XqLvM86PtAb4w7bADQ&q=resize+height+uitextview&oq=resizing+height+of+uite&gs_l=psy-ab.3.0.0i22i30.6102.13677..15026...0.1..0.122.1897.20j3......0....1..gws-wiz.......0i71j35i39j0i273j0j0i67j0i131i67j0i131j0i22i10i30j33i22i29i30.14giIp0ZcGY how to modify size
            messageBoxHeight.constant = 60
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView){
        let rows = (messageBox.contentSize.height - messageBox.textContainerInset.top - messageBox.textContainerInset.bottom) / messageBox.font!.lineHeight
        if(rows>=2){
            messageBoxHeight.constant = 60
        }
        messageBox.scrollRangeToVisible(NSMakeRange(messageBox.text.count-1,0))
//        let newPosition = messageBox.endOfDocument
//        messageBox.selectedTextRange = messageBox.textRange(from: newPosition, to: newPosition)
    }
    func textViewDidEndEditing(_ textView: UITextView){
        messageBox.scrollRangeToVisible(NSMakeRange(messageBox.text.count-1,0))
        messageBoxHeight.constant = 30
        print("paused!")
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
