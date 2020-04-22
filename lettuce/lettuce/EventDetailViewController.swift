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
import CoreLocation

class EventDetailViewController: UIViewController {
    
    var event: DocumentSnapshot!

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet var tags: UICollectionView!
//    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var mpImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet var numberOfPeople: UILabel!
    @IBOutlet var bookmarked: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var locationInfo: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let locManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    var addressOfEvent: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        reloadButtons()

        
    }
    
    func initView() {
        
        
        locManager.requestWhenInUseAuthorization()

        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
        }
        
        if let title = event.get("name") as? String {
            eventTitle.text = title
            eventTitle.adjustsFontSizeToFitWidth = true
            eventTitle.minimumScaleFactor = 0.5
        }
        
        if let description = event.get("description") as? String{
            descriptionLabel.text = description
        }
        
        if let username = event.get("username") as? String{
//            usernameLabel.text = username
            profileButton.setTitle(username, for: .normal)
        }
        
        if let address = event.get("address") as? String {
            addressOfEvent = address
        }


        if let location = event.get("location") as? GeoPoint {
            let dist = distance(lat1: self.currentLocation.coordinate.latitude, lon1: self.currentLocation.coordinate.longitude, lat2: location.latitude, lon2: location.longitude)
            
            locationLabel.text = String(format:"%.1f", dist)
        }else{
//            print("Couldn't parse location")
        }
        
        if let going = event.get("going") as? [String] {
            let peopleNum = going.count
            numberOfPeople.text = String(peopleNum)
        }
        
        if let timeStamp = event.get("date_time") as? Timestamp {
            let date = timeStamp.dateValue()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm MM/dd/yyyy"
            let dateLabel = formatter.string(from: date)
            
            timeLabel.text = dateLabel
        }
        
        
//        descriptionLabel.isScrollEnabled = false
//        descriptionLabel.isEditable = false
        
        if let ei_url = event.get("photos_url") as? String {
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
        
        self.locationInfo.adjustsFontSizeToFitWidth = true
        self.locationInfo.minimumScaleFactor = 0.5
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                self.event = document
            }
            else {
                
            }
            
            if self.goingToEvent() {
                self.joinButton.setTitle("Joined!", for: .normal)
                self.locationInfo.text = self.addressOfEvent
                self.joinButton.isEnabled = false
                
            }
            
            else if self.alreadyRequested() {
                self.joinButton.setTitle("Requested!", for: .normal)
                self.locationInfo.text = "Address will be available upon approval."
                self.joinButton.isEnabled = false
            }
            else{
                self.locationInfo.text = "Address will be available upon approval."
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
    
    @IBAction func takeToProfile(_ sender: Any) {
        // take user to the profile of the user that created the event
        
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

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    

    
}
