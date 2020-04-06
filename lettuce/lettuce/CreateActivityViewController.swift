//
//  CreateActivityViewController.swift
//  lettuce
//
//  Created by Alex Appel on 2/26/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class CreateActivityViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventCategories[row]
    }
    
    
    
    let eventCategories:[String] = ["Party", "Outdoors", "Zoom", "LAN Party", "Board Games", "Chillin"]
    
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventTime: UIDatePicker!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var eventCategory: UIPickerView!
    @IBOutlet weak var eventBackgroundURL: UITextField!
    @IBOutlet weak var requestApproval: UISwitch!
    
    
    let db = Firestore.firestore()
    let currentUser = (Auth.auth().currentUser)!
    var school = ""
    let locationManager = CLLocationManager()
    var placeMark: CLPlacemark!
    var coordinates: CLLocationCoordinate2D!
    var coordinatesToSubmit: CLLocationCoordinate2D!
    var addressString = ""
    var didPressLocButton = false
    
    //Set text field deligate information obtained from https://medium.com/@andy.nguyen.1993/autolayout-for-scrollview-keyboard-handling-in-ios-5a47d73fd023
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
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
                self.descriptionText.text = "Enter An Event Descripton"
                self.descriptionText.textColor = UIColor.gray
                self.descriptionText.delegate = self
                self.addressText.delegate = self
                self.coordinates = CLLocationCoordinate2D.init()
                self.coordinatesToSubmit = CLLocationCoordinate2D.init()
        }
        
        
        //How to get location information: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

    }
    
    
    //How to get get location information: https://www.ioscreator.com/tutorials/request-permission-core-location-ios-tutorial
    func getLoction(){
        // 1
        let status = CLLocationManager.authorizationStatus()

        switch status {
            // 1
        case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return

            // 2
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break

        @unknown default:
            break
        }

        // 4
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }

    // 1
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("getting user loc")
        if let currentLocation = locations.last {
            let locationCordinates = currentLocation.coordinate
            coordinates = currentLocation.coordinate
            let location = CLLocation(latitude: locationCordinates.latitude, longitude: locationCordinates.longitude)
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

                // Place details
                //How to construct string address: https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
                self.placeMark = placemarks?[0]
                
                self.addressString = ""
                if let sublocal = self.placeMark.subLocality {
                    self.addressString = self.addressString + sublocal + ", "
                }
                if let street = self.placeMark.thoroughfare {
                    self.addressString = self.addressString + street + ", "
                }
                if let city = self.placeMark.locality {
                    self.addressString = self.addressString + city + ", "
                }
                if let country = self.placeMark.country {
                    self.addressString = self.addressString + country + ", "
                }
                if let postalCode = self.placeMark.postalCode {
                    self.addressString = self.addressString + postalCode + " "
                }
                self.addressText.text = self.addressString
            })
            
        }
    }

    // 2
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func initView(){
        eventCategory.delegate = self
        eventCategory.dataSource = self
    }
    
    
    
    func handleAddActivity() {
//        let category = eventCategories[eventCategory.selectedRow(inComponent: 0)]
       // Add a new document with a generated ID
        var backgroundURL = ""
        if(eventBackgroundURL.text == ""){
            backgroundURL = "no_image"
        }
        else{
            backgroundURL = eventBackgroundURL.text ?? "no_image"
        }
       var ref: DocumentReference? = nil
        
       ref = db.collection("events").addDocument(data: [
           "date_time": combineDateWithTime(date: eventDate.date, time: eventTime.date)!,
           "category": eventCategories[eventCategory.selectedRow(inComponent: 0)],
           "location": GeoPoint(latitude: self.coordinatesToSubmit!.latitude, longitude: self.coordinatesToSubmit!.longitude),
           "address": self.addressText.text ?? "No Address provided",
           "name": titleText.text!,
           "description": descriptionText.text!,
           "owner": currentUser.uid,
           "photos_url": backgroundURL,
           "school": self.school,
           "needApproval": requestApproval.isOn,
           "username": currentUser.displayName!,
           "requested": [],
           "going": [currentUser.uid]
       ]) { err in
           if let err = err {
               print("Error adding document: \(err)")
           } else {
            print("Document added with ID: \(ref!.documentID)")
            self.titleText.text = ""
            self.descriptionText.text = ""
            self.eventDate.setDate(Date(), animated: true)
            self.eventTime.setDate(Date(), animated: true)
            self.addressText.text = ""
            self.eventCategory.selectRow(0, inComponent: 0, animated: true)
            self.eventBackgroundURL.text = ""
            backgroundURL = ""
            self.requestApproval.isOn = false
            self.descriptionText.text = "Enter An Event Descripton"
            self.descriptionText.textColor = UIColor.gray
           }
       }
//        print("add handled")
    }
    
    @IBAction func goBtnPressed(_ sender: Any) {
        if (titleText.text! != "" && descriptionText.text! != "") {
            handleAddActivity()
        }
        else {
            let alert = UIAlertController(title: "Uh oh!", message: "Please make sure your activity has a Title and a Description.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func currentLocation(_ sender: UIButton) {
        self.descriptionText.becomeFirstResponder()
        self.addressText.text = ""
        self.addressText.text = addressString
        self.coordinatesToSubmit = self.coordinates
        self.didPressLocButton = true
        getLoction()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //how to combine date and time: https://gist.github.com/justinmfischer/0a6edf711569854c2537
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
//        print("editing!!!")
        descriptionText.textColor = UIColor.black
        descriptionText.text = ""
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if(textField == self.addressText){
            addressText.text = ""
            self.didPressLocButton = false
        }
    }
    
    //how to covert address from string to values: https://stackoverflow.com/questions/42279252/convert-address-to-coordinates-swift
    func textFieldDidEndEditing(_ textField: UITextField){
        if let address = addressText.text {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    // handle no location found
                    self.coordinatesToSubmit.longitude = 0
                    self.coordinatesToSubmit.latitude = 0
                    return
                }
                // Use your location
                self.coordinatesToSubmit =  location.coordinate
            }
        }
    }
    
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
}
