//
//  RegisterViewConroller.swift
//  lettuce
//
//  Created by Alex Appel on 2/16/20.
//  Copyright © 2020 Alex Appel, Uki Malla. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class RegisterViewController: UIViewController, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        universityList.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return universityList[row]
//    }
    
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var universityPicker: UIPickerView!
    
    let universityList:[String] = ["Washington University IN St. Louis", "University of Illinois Champaign", "Zoom University"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.usernameText.delegate = self
        self.emailText.delegate = self
        
        initView()
    }
    
    func initView(){
//        universityPicker.delegate = self
//        universityPicker.dataSource = self
    }
    

    @IBAction func onPressedNext(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let register2VC = segue.destination as? Register2ViewController{
            register2VC.firstNameText = self.firstNameText.text
            register2VC.lastNameText = self.lastNameText.text
            register2VC.usernameText = self.usernameText.text
            register2VC.emailText = self.emailText.text
//            register2VC.universityName = universityList[self.universityPicker.selectedRow(inComponent: 0)]
        }
     
    }

}
