//
//  FeedViewController.swift
//  lettuce
//
//  Created by Alex Appel on 2/24/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var theTableView: UITableView!
    var events:[QueryDocumentSnapshot] = []
    var selectedItemIndex = 0
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser!.uid
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "eventDetails") as? EventCard2 {
            
            if let title = events[indexPath.item].get("name") as? String {
                myCell.eventTitle.text = title
                myCell.eventTitle.adjustsFontSizeToFitWidth = true
                myCell.eventTitle.minimumScaleFactor = 0.5
            }else{
//                print("Couldn't parse title")
                myCell.eventTitle.text = nil
            }
            
            myCell.documentID = events[indexPath.item].documentID
            

            if let categoryIconURL = events[indexPath.item].get("photos_url") as? String {
                if let categoryIconActualURL = URL(string: categoryIconURL){
                    let categoryIconData = try? Data(contentsOf: categoryIconActualURL)
                    if let data = categoryIconData {
                        let categoryIcon = UIImage(data: data)
                        myCell.categoryIcon.image = categoryIcon
                        myCell.categoryIcon.contentMode = .scaleAspectFill
//                        myCell.noImgLabel.isHidden = true
                    }
                    else {
                        print("could not get data")
                        myCell.categoryIcon.image = nil
    //                        myCell.noImgLabel.isHidden = false
                    }
                }
                else {
                    myCell.categoryIcon.image = nil
//                    myCell.noImgLabel.isHidden = false
                    
                }
            }else{
//                myCell.noImgLabel.isHidden = false
                myCell.categoryIcon.image = nil
    //                print("Couldn't parse url")
            }
            
            myCell.locationMarker.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
//            myCell.locationMarker.tintColor = UIColor.label
            
            let templateImage = myCell.locationMarker?.image?.withRenderingMode(.alwaysTemplate)
            myCell.locationMarker.image? = templateImage!
            myCell.locationMarker.tintColor = UIColor.label
            
//            if let mp_url = events[indexPath.item].get("photos_url") as? String{
//                if let mainPictureActualURL = URL(string: mp_url){
//                    let mainPictureData = try? Data(contentsOf: mainPictureActualURL)
//                    if let data = mainPictureData {
//                        let mainPictureImage = UIImage(data: data)
//                        myCell.eventImage.image = mainPictureImage
//                        myCell.eventImage.contentMode = .scaleAspectFill
//                        myCell.noImgLabel.isHidden = true
//                    }
//                    else {
//                        print("could not get data")
//                        myCell.eventImage.image = nil
////                        myCell.noImgLabel.isHidden = false
//                    }
//                }
//                else {
//                    myCell.eventImage.image = nil
//                    myCell.noImgLabel.isHidden = false
//
//                }
//            }else{
//                myCell.noImgLabel.isHidden = false
//                myCell.eventImage.image = nil
////                print("Couldn't parse url")
//            }
            
            
//            if let description = events[indexPath.item].get("description") as? String {
//                myCell.descriptionLabel.text = description
//            }else{
////                print("Couldn't parse description")
//                myCell.descriptionLabel.text = nil
//            }
            
//            if let username = events[indexPath.item].get("username") as? String {
//                myCell.userNameLabel.text = username
//            }else{
////                print("Couldn't parse username")
//                myCell.userNameLabel.text = nil
//            }
//
            if let location = events[indexPath.item].get("address") as? String {
//                myCell.distance.text = location
                myCell.distance.text = "20 mi."
            }else{
//                print("Couldn't parse location")
//                myCell.userNameLabel.text = nil
            }
            
            
            
            
            myCell.bookmarkIcon.setImage(UIImage(systemName: "bookmark"), for: .normal)
            myCell.bookmarkIcon.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
            
            myCell.bookmarkIcon.tintColor = UIColor.label
            
                        
            print("currentUser: " + Auth.auth().currentUser!.uid)

            db.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser!.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            if let favoritedEventsList = document.get("favoritedEventsList") as? [String]{
                                                        
                            if favoritedEventsList.contains(myCell.documentID) {
//                                myCell.favoriteButton.isHighlighted = true
                                myCell.bookmarkIcon.isSelected = true
                            }
                            else {
//                                myCell.favoriteButton.isHighlighted = false
                                myCell.bookmarkIcon.isSelected = false
                            }
                            }

                        }
                    }
            }
            
        
            myCell.bookmarkIcon.addTarget(self, action: #selector(favorite(button:)), for: .touchUpInside)

            myCell.bookmarkIcon.tag = indexPath.row
            
//            if(indexPath.row % 2 == 0){
//                myCell.backgroundColor = UIColor.white
//            }
//            else{
//                myCell.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
//            }
            
            
            myCell.backgroundColor = UIColor.systemBackground;
            
//            myCell.descriptionLabel.isScrollEnabled = false
//            myCell.descriptionLabel.isEditable = false
            
            
            return myCell
        }else{
//            print("Couldn't convert to event card")
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "myCell")
        
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        selectedItemIndex = indexPath.item
        return true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
//        loadEvents()
//        print(events.count)
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        events.removeAll()
        reloadEvents()
    }
    
    
    func reloadEvents(){

        events.removeAll()
        
        
        db.collection("events").getDocuments{ (querySnapshot, err) in
            if let err = err{
                print("Error getting documents: \(err)")
            }else{
                for document in querySnapshot!.documents{
                    if document.get("owner") as! String != self.currentUser {
                        self.events.append(document)
                    }
                    if let cat = document.get("category"){
                        print("cat: ")
                        print(cat)
                    }
                    else{
                        print("cat not found")
                    }
                }
                self.theTableView.reloadData()
                
            }
            
        }
    }
    
    @objc func favorite(button: UIButton) {
        button.isSelected = !button.isSelected
        
        let buttonTag = button.tag
        
        let documentID = events[buttonTag].documentID
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if button.isSelected {
                            print("favorited event!")
                            
                            // Atomically add a new event to the "favoritedEventList" array field.
                             document.reference.updateData([
                                 "favoritedEventsList": FieldValue.arrayUnion([documentID])
                             ])

                        }
                        else {
                            print("unfavorited event!")
                           // Atomically remove an event from the "favoritedEventList" array field.
                           document.reference.updateData([
                               "favoritedEventsList": FieldValue.arrayRemove([documentID])
                           ])
                            
                        }
                    }
                }
        }
    

    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

        let eventDetailVC = segue.destination as! EventDetailViewController
        eventDetailVC.event = events[selectedItemIndex]
    }
    
}
