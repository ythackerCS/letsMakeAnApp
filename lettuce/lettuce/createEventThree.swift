//
//  createEventThree.swift
//  lettuce
//
//  Created by Yash Thacker on 4/21/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit
import CoreLocation

class createEventThree: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet var titleContinued: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var eventLocation: UITextField!
    @IBOutlet var myLocation: UIButton!
    
    var eventTitle3: String = ""
    var eventDescription3: String = ""
    var eventImage3: UIImage = UIImage.init()
    var addressOfEvent: String = "" 
    var longLatOfevent: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    var eventDateCalculated: Date = Date.init()
    var placeMark: CLPlacemark!
    var coordinates: CLLocationCoordinate2D!
    var addressString = ""
    var currentTimeZone: TimeZone?
    
    var alerted = false
    var locationIssue = false
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vc3")
        print(eventTitle3)
        print(eventDescription3)
        print(eventImage3)
        print(addressOfEvent)
        print(longLatOfevent)
        titleContinued.text = eventTitle3
        //How to get location information: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        getLoction()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        eventLocation.delegate = self
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
            self.longLatOfevent = coordinates
               let location = CLLocation(latitude: locationCordinates.latitude, longitude: locationCordinates.longitude)
               
               let geoCoder = CLGeocoder()
               geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

                   // Place details
                   //How to construct string address: https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
                   self.placeMark = placemarks?[0]
                   self.currentTimeZone = self.placeMark.timeZone
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
                
                self.addressOfEvent = self.addressString
               })
           }
       }

       // 2
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(error)
       }
    
    
    //how to covert address from string to values: https://stackoverflow.com/questions/42279252/convert-address-to-coordinates-swift
    func textFieldDidEndEditing(_ textField: UITextField){
        print("converting")
        if let address = eventLocation.text {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    // handle no location found
                    self.longLatOfevent.longitude = 0
                    self.longLatOfevent.latitude = 0
                    return
                }
                // Use your location
                self.longLatOfevent =  location.coordinate
                self.addressOfEvent = self.eventLocation.text!
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!alerted){
            let alert = UIAlertController(title: "Important!", message: "Please make sure your click 'Done' on keyboard to ensure location conversion.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            alerted = true
        }
    }
    
    @IBAction func getMyLocation(_ sender: Any) {
        eventLocation.text = self.addressString
        if let coordinates = self.coordinates {
            longLatOfevent = coordinates
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventPageFour" {
            if let createEventFour = segue.destination as? createEventFour {
                if let eventDate = datePicker, let eventTime = timePicker {
                    
                    eventDateCalculated = combineDateWithTime(date: eventDate.date, time: eventTime.date)!
                    
                    createEventFour.eventTitle4 = eventTitle3 ;
                    createEventFour.eventDescription4 = eventDescription3 ;
                    createEventFour.eventImage4 = eventImage3;
                    createEventFour.addressOfEvent4 = addressOfEvent;
                    createEventFour.longLatOfevent4 = longLatOfevent;
                    createEventFour.eventDate4 = eventDateCalculated as Date;
                }
            }
        }
    }
    
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        
        var calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        calendar.timeZone = currentTimeZone!
//        mergedComponments.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        
        
        return calendar.date(from: mergedComponments)
    }

    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "toEventPageFour" {
                if (eventLocation.text! == "") {
                    let alert = UIAlertController(title: "Uh oh!", message: "Please make sure all information is filled.", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                               NSLog("The \"OK\" alert occured.")
                               }))
                               self.present(alert, animated: true, completion: nil)
                    return false
                }
                if (longLatOfevent.latitude == 0 && longLatOfevent.longitude == 0 && !locationIssue) {
                    let alert = UIAlertController(title: "Uh oh!", message: "Location could not properly be converted and will appear for all users.", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                               NSLog("The \"OK\" alert occured.")
                               }))
                               self.present(alert, animated: true, completion: nil)
                            locationIssue = true
                    return false
                }
            }
        }
        return true
    }
}

