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
import FirebaseStorage

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
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        guard let data = eventImage4.jpegData(compressionQuality: 1.0) else {
            print("Something went wrong")
            return
        }
        
        let imageName = UUID().uuidString
        
        let filePath = "images"
        let storageRef = Storage.storage().reference().child(imageName)
        
        var imageURL = ""
        
        if let uploadData = eventImage4.pngData(){
            storageRef.putData(uploadData, metadata: nil
                , completion: { (metadata, error) in
//                    self.hideActivityIndicator(view: self.view)
                    if error != nil {
//                        self.writeDatabaseCustomer()
//                        print(“error”)
                        return
                    }
                    else {
                        storageRef.downloadURL(completion: { (url, error) in
//                            print("Image URL: \((url?.absoluteString)!)”)
//                            self.writeDatabaseCustomer(imageUrl: (url?.absoluteString)!)
                            imageURL = url!.absoluteString
                            print(imageURL)
                            
                            //        let category = eventCategories[eventCategory.selectedRow(inComponent: 0)]
                            // Add a new document with a generated ID
                            var ref: DocumentReference? = nil
                            
                            ref = self.db.collection("events").addDocument(data: [
                                "date_time": self.eventDate4,
                                "category": "red",
                                "location": GeoPoint(latitude: self.longLatOfevent4.latitude, longitude: self.longLatOfevent4.longitude),
                                "address": self.addressOfEvent4,
                                "name": self.eventTitle4,
                                "description": self.eventDescription4,
                                "owner": self.currentUser.uid,
                                "photos_url": imageURL,
                                "school": self.school,
                                "needApproval": self.requireApproval.isOn,
                                "username": self.currentUser.displayName!,
                                "requested": [],
                                "going": [self.currentUser.uid],
                                //               "expected": Int(expectedNumberOfPeople.text!)!
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                }
                            }
                            
                        })
                    }})
        }
        
    }
    
    
    @IBAction func createEvent(_ sender: Any) {
        handleAddActivity()
    }
}
