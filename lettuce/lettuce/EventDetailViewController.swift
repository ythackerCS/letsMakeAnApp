//
//  EventDetailViewController.swift
//  lettuce
//
//  Created by Alex Appel on 2/24/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventDetailViewController: UIViewController {
    
    var event: DocumentSnapshot!

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet var tags: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var mpImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet var numberOfPeople: UILabel!
    @IBOutlet var bookmarked: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        reloadButtons()
    }
    
    func initView(){
        if let title = event.get("name") as? String{
            eventTitle.text = title
        }else{
//            print("Couldn't parse title for Event")
        }
        
        
        if let description = event.get("description") as? String{
            descriptionLabel.text = description
        }else{
//            print("Couldn't parse description")
        }
        
        if let username = event.get("username") as? String{
            usernameLabel.text = username
        }else{
//            print("Couldn't parse username")
        }
        if let location = event.get("location") as? String{
            locationLabel.text = location
        }else{
//            print("Couldn't parse location")
        }
        
        
        descriptionLabel.isScrollEnabled = false
        descriptionLabel.isEditable = false
        
        if let ei_url = event.get("photos_url") as? String{
            let eventImageActualURL = URL(string: ei_url)
            if let url = eventImageActualURL {
                let mainPictureData = try? Data(contentsOf: url)
                if let data = mainPictureData {
                    let mainPictureImage = UIImage(data: data)
                    mpImageView.image = mainPictureImage
                }
            }
        } else {
            mpImageView.isHidden = false
            mpImageView.image = nil
        }
    }
    
    @IBAction func joinEvent(_ sender: Any) {
        let db = Firestore.firestore()
        if !requireApproval() {
            db.collection("events").document(event.documentID).updateData([
                "going" : FieldValue.arrayUnion([(Auth.auth().currentUser?.uid)!])
            ])
            reloadButtons()
            return
        }

        if !goingToEvent() {
            if !alreadyRequested() {
                db.collection("events").document(event.documentID).updateData([
                    "requested" : FieldValue.arrayUnion([(Auth.auth().currentUser?.uid)!])
                ])
            }
        }
        reloadButtons()
    }
    
    func reloadButtons() {
        let db = Firestore.firestore()
        
        let docRef = db.collection("events").document(event.documentID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                self.event = document
            }
            else {
                
            }
            
            if self.goingToEvent() {
                self.joinButton.setTitle("Joined!", for: .normal)
                self.joinButton.isEnabled = false
                
            }
            
            if self.alreadyRequested() {
                self.joinButton.setTitle("Requested!", for: .normal)
                self.joinButton.isEnabled = false
            }
            
        }
        
//        db.collection("events").document(event?.documentID) {
//            (querrySnapshot, err) in
//
//            for document in querrySnapshot!.documents{
//                self.event = document
//            }
//
//
//
//            if(self.goingToEvent()){
//                self.joinButton.setTitle("Already Joined!", for: .normal)
//                self.joinButton.isEnabled = false
//
//            }
//
//            if(self.alreadyRequested()){
//                self.joinButton.setTitle("Requested!", for: .normal)
//                self.joinButton.isEnabled = false
//            }
//
//
//        }
        
    }
    
    
    func goingToEvent() -> Bool {
        guard let goingList = event?.get("going") as? [String],
              let currentUid = Auth.auth().currentUser?.uid else {
            return false
        }

        return goingList.contains(currentUid)
    }
    
    func alreadyRequested() ->Bool {
        guard let requestedList = event?.get("requested") as? [String],
              let currentUid = Auth.auth().currentUser?.uid else {
            return false
        }

        return requestedList.contains(currentUid)
        
    }
    
    func requireApproval() ->Bool {
        if let needApproval = event?.get("needApproval") {
            return needApproval as! Bool
        }
        return false
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
