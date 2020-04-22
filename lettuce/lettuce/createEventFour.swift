//
//  createEventFour.swift
//  lettuce
//
//  Created by Yash Thacker on 4/21/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore


class createEventFour: UIViewController {


    
    @IBOutlet var expectedNumberOfPeople: UITextField!
    @IBOutlet var ageRestriction: UISwitch!
    @IBOutlet var requireApproval: UISwitch!
    @IBOutlet var tagsList: UICollectionView!
    @IBOutlet var publishEvent: UIButton!
    
    var eventTitle4: String = ""
    var eventDescription4: String = ""
    var eventImage4: UIImage = UIImage.init()
    var addressOfEvent4: String = ""
    var longLatOfevent4: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    var eventDate4: Date = Date.init()
    var school = ""
    
    let db = Firestore.firestore()
    let currentUser = (Auth.auth().currentUser)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vc4")
        print(eventTitle4)
        print(eventDescription4)
        print(eventImage4)
        print(addressOfEvent4)
        print(longLatOfevent4)
        print(eventDate4)
        
        db.collection("users").whereField("id", isEqualTo: currentUser.uid)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let school = document.get("university") as? String{
                        self.school = school
                    }
                }
            }
        }
    }
    
    func handleAddActivity() {
    //        let category = eventCategories[eventCategory.selectedRow(inComponent: 0)]
           // Add a new document with a generated ID
           var ref: DocumentReference? = nil
            
           ref = db.collection("events").addDocument(data: [
               "date_time": eventDate4,
               "category": "red",
               "location": GeoPoint(latitude: longLatOfevent4.latitude, longitude: longLatOfevent4.longitude),
               "address": addressOfEvent4,
               "name": eventTitle4,
               "description": eventDescription4,
               "owner": currentUser.uid,
               "photos_url": "backgroundURL",
               "school": self.school,
               "needApproval": requireApproval.isOn,
               "username": currentUser.displayName!,
               "requested": [],
               "going": [currentUser.uid],
//               "expected": Int(expectedNumberOfPeople.text!)!
           ]) { err in
               if let err = err {
                   print("Error adding document: \(err)")
               } else {
                print("Document added with ID: \(ref!.documentID)")
               }
           }

        }


    @IBAction func createEvent(_ sender: Any) {
        handleAddActivity()
    }
}
