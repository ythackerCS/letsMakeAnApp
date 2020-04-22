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
import CoreLocation

class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var image: UITabBarItem!
    
    @IBOutlet weak var theTableView: UITableView!
    var events:[QueryDocumentSnapshot] = []
    var selectedItemIndex = 0
    
    let locManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    
    func initView() {
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
        if let myCell = theTableView.dequeueReusableCell(withIdentifier: "eventDetails") as? EventCard2 {
            
            if let title = events[indexPath.item].get("name") as? String{
                myCell.eventTitle.text = title
            }else{
                //                print("Couldn't parse title")
            }
            
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
                let dist = distance(lat1: self.currentLocation.coordinate.latitude, lon1: self.currentLocation.coordinate.longitude, lat2: location.latitude, lon2: location.longitude)
                
                myCell.distance.text = String(format:"%.1f mi.", dist)
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
                
                myCell.goingButton.setTitle("Going: \(numGoing)", for: .normal)
            }
            
            if let requested = events[indexPath.item].get("requested") as? [String] {
                let numRequested = requested.count
                
                myCell.requestedButton.setTitle("Requests: \(numRequested)", for: .normal)
            }
            
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
