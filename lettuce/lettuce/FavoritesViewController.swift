//
//  FavoritesViewController.swift
//  lettuce
//
//  Created by Alex Appel on 2/24/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var theTableView: UITableView!
    var events:[DocumentSnapshot] = []
    var selectedItemIndex = 0
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "eventDetails") as? EventCard2 {
                        
            if let title = events[indexPath.item].get("name") as? String{
//                print("getting title")
                myCell.eventTitle.text = title
                myCell.eventTitle.adjustsFontSizeToFitWidth = true
                myCell.eventTitle.minimumScaleFactor = 0.5
            }
            else {
                print("Couldn't parse title")
            }
            
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
            
//            if let description = events[indexPath.item].get("description") as? String{
//                myCell.descriptionLabel.text = description
//            }else{
//                print("Couldn't parse description")
//            }
            
//            if let username = events[indexPath.item].get("username") as? String{
//                myCell.userNameLabel.text = username
//            }else{
//                print("Couldn't parse username")
//            }
            
            if let location = events[indexPath.item].get("address") as? String {
//                myCell.distance.text = location
                myCell.distance.text = "20 mi."
            }else{
//                print("Couldn't parse location")
//                myCell.userNameLabel.text = nil
            }
            
//            myCell.descriptionLabel.isScrollEnabled = false
//            myCell.descriptionLabel.isEditable = false
            
            myCell.bookmarkIcon.isSelected = true
            
//            myCell.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
//            myCell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
            
            myCell.bookmarkIcon.addTarget(self, action: #selector(unfavorite(button:)), for: .touchUpInside)

            myCell.bookmarkIcon.tag = indexPath.row
            
            return myCell
        }else{
            print("Couldn't convert to event card")
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
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        events.removeAll()
        loadEvents()
    }
    
    
    func loadEvents(){
        let db = Firestore.firestore()
        
        let currentUser = (Auth.auth().currentUser)!.uid
        
        db.collection("users").whereField("id", isEqualTo: currentUser)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let favoritedEventsList = document.get("favoritedEventsList") as! [String]
                                                    
                        for event in favoritedEventsList {
                            
                            let docRef = db.collection("events").document(event)
                            
                            docRef.getDocument { (snapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                }
                                else {
                                    self.events.append(snapshot!)
                                }
                                self.theTableView.reloadData()
                            }
                               
                        }

                    }
                }
        }
        
        
    }
    
    @objc func unfavorite(button: UIButton){
        button.isSelected = !button.isSelected
        
        let buttonTag = button.tag
        
//        print("fire")
//        print(buttonTag)
//
//        print("highlighted: ")
//        print(button.isHighlighted)
//        print(button.isSelected)
//
//        print(button)
        
        let documentID = events[buttonTag].documentID
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
//                        print("unfavorited event!")
                       // Atomically remove an event from the "favoritedEventList" array field.
                       document.reference.updateData([
                           "favoritedEventsList": FieldValue.arrayRemove([documentID])
                       ])
                        self.events.remove(at: buttonTag)
                    }
                    self.theTableView.reloadData()
                }
        }
    

    }
}
