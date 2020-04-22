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
import CoreLocation

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var theTableView: UITableView!
    var events:[QueryDocumentSnapshot] = []
    var selectedItemIndex = 0
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser!.uid
    
    let locManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    
    func initView(){
        theTableView.delegate = self
        theTableView.dataSource = self
        
        locManager.requestWhenInUseAuthorization()

        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myCell = theTableView.dequeueReusableCell(withIdentifier: "eventDetails") as? EventCard2 else {
            return UITableViewCell(style: .default, reuseIdentifier: "myCell")
        }

        if let title = events[indexPath.item].get("name") as? String {
            myCell.eventTitle.text = title
            myCell.eventTitle.adjustsFontSizeToFitWidth = true
            myCell.eventTitle.minimumScaleFactor = 0.5
        } else {
//                print("Couldn't parse title")
            myCell.eventTitle.text = nil
        }
        
        myCell.documentID = events[indexPath.item].documentID

        myCell.categoryIcon.image = nil
        if let categoryIconURL = events[indexPath.item].get("photos_url") as? String,
            let categoryIconActualURL = URL(string: categoryIconURL) {

            DispatchQueue.global(qos: .background).async {
                // fetch image on background thread
                if let categoryIconData = try? Data(contentsOf: categoryIconActualURL) {
                    DispatchQueue.main.async {
                        // update image on main thread
                        let categoryIcon = UIImage(data: categoryIconData)
                        myCell.categoryIcon.image = categoryIcon
                        myCell.categoryIcon.contentMode = .scaleAspectFill
                    }
                }
            }
        }
        
        myCell.locationMarker.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
//            myCell.locationMarker.tintColor = UIColor.label
        
        let templateImage = myCell.locationMarker?.image?.withRenderingMode(.alwaysTemplate)
        myCell.locationMarker.image? = templateImage!
        myCell.locationMarker.tintColor = UIColor.label
        
        if let location = events[indexPath.item].get("location") as? GeoPoint {
            
            if let myCurrentLocation = self.currentLocation {
                let dist = distance(lat1: myCurrentLocation.coordinate.latitude, lon1: myCurrentLocation.coordinate.longitude, lat2: location.latitude, lon2: location.longitude)
                
                myCell.distance.text = String(format:"%.1f mi.", dist)
            }
            
            
        }
        
        if let timeStamp = events[indexPath.item].get("date_time") as? Timestamp {
            let date = timeStamp.dateValue()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let dateLabel = formatter.string(from: date)
            
            myCell.eventDate.text = dateLabel
        }
        
        if let going = events[indexPath.item].get("going") as? [String] {
            let numGoing = going.count
                        
            switch (numGoing) {
            case _ where numGoing <= 5:
                myCell.personIcon1.isHidden = true
                myCell.personIcon2.isHidden = true
                break
            case _ where (numGoing > 5 && numGoing <= 11):
                myCell.personIcon1.isHidden = true
                break
            default:
                break
            }
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
    
    // The following was obtained from:
    // https://www.geodatasource.com/developers/swift
    
    func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }

    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }

    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        // In miles
        dist = dist * 0.8684
        return dist
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
