//
//  MyEventsViewController.swift
//  lettuce
//
//  Created by Alex Appel on 3/19/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var image: UITabBarItem!
    
    @IBOutlet weak var theTableView: UITableView!
    var events:[QueryDocumentSnapshot] = []
    var selectedItemIndex = 0
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "eventDetails") as? EventCard{
            
            if let title = events[indexPath.item].get("name") as? String{
                myCell.eventTitle.text = title
            }else{
//                print("Couldn't parse title")
            }
            
            if let mp_url = events[indexPath.item].get("photos_url") as? String{
                if let mainPictureActualURL = URL(string: mp_url){
                    let mainPictureData = try? Data(contentsOf: mainPictureActualURL)
                    if let data = mainPictureData{
                        let mainPictureImage = UIImage(data: data)
                        myCell.eventImage.image = mainPictureImage
                        myCell.eventImage.contentMode = .scaleAspectFill
                        myCell.noImgLabel.isHidden = true
                    }
                    else {
                        myCell.eventImage.image = nil
                        myCell.noImgLabel.isHidden = false
                    }
                }
            }else{
                myCell.noImgLabel.isHidden = false
                myCell.eventImage.image = nil
//                print("Couldn't parse url")
            }
            
            if let description = events[indexPath.item].get("description") as? String{
                myCell.descriptionLabel.text = description
            }else{
//                print("Couldn't parse description")
            }
            
            if let username = events[indexPath.item].get("username") as? String{
                myCell.userNameLabel.text = username
            }else{
//                print("Couldn't parse username")
            }
            
            if let location = events[indexPath.item].get("location") as? String{
                
                myCell.location.text = location
            }else{
//                print("Couldn't parse location")
            }
            
            
            myCell.descriptionLabel.isScrollEnabled = false
            myCell.descriptionLabel.isEditable = false
            
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
        events.removeAll()
        loadEvents()
    }
    
    
    func loadEvents(){
        let db = Firestore.firestore()
        
        let currentUser = (Auth.auth().currentUser)!
        
        db.collection("events").whereField("owner", isEqualTo: currentUser.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.events.append(document)
                    }
                }
                self.theTableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let requestedVC = segue.destination as? RequestedViewController
        
        if requestedVC != nil {
            requestedVC!.event = events[selectedItemIndex]
        }
        
        let goingVC = segue.destination as? GoingTableViewController
        
        if goingVC != nil {
            goingVC!.event = events[selectedItemIndex]
        }
        
        
    }
       
    
}
