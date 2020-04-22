//
//  createEventOneViewController.swift
//  lettuce
//
//  Created by Yash Thacker on 4/21/20.
//  Copyright © 2020 Alex Appel. All rights reserved.
//

import UIKit

class createEventOneViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var eventTitle: UITextField!
    @IBOutlet var eventDescription: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDescription.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventPageTwo" {
            if let createEventTwo = segue.destination as? createEventTwo {
                if let eventTitle = eventTitle, let eventDescription = eventDescription {
                    createEventTwo.eventTitle2 = (eventTitle.text ?? "No Name Given") as String;
                    createEventTwo.eventDescription2 = (eventDescription.text ?? "No description given") as String;
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "toEventPageTwo" {
                if (eventTitle.text! == "" || eventDescription.text! == "") {
                    let alert = UIAlertController(title: "Uh oh!", message: "Please make sure all information is filled.", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                               NSLog("The \"OK\" alert occured.")
                               }))
                               self.present(alert, animated: true, completion: nil)
                    return false
                }
            }
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        eventDescription.text = String()
    }

}
