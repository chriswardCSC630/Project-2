//
//  NewUserViewController.swift
//  Memories
//
//  Created by Eric on 4/28/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    let badColor: UIColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.3)
    let goodColor: UIColor = UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.3)
    var validFirstName: Bool = false
    var validLastName: Bool = false
    var validUsername: Bool = false
    var validPassword: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        firstName.addTarget(self, action: #selector(checkForValidFirstName), for: .editingChanged)
        lastName.addTarget(self, action: #selector(checkForValidLastName), for: .editingChanged)
        username.addTarget(self, action: #selector(checkForValidUsername), for: .editingChanged)
        password.addTarget(self, action: #selector(checkForValidPassword), for: .editingChanged)
        confirmPassword.addTarget(self, action: #selector(checkForSamePassword), for: .editingChanged)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNewUser(_ sender: Any) {
        firstName.isEnabled = false
        lastName.isEnabled = false
        username.isEnabled = false
        password.isEnabled = false
        confirmPassword.isEnabled = false
        performSegue(withIdentifier: "saveNewUserSegue", sender: self)
        // then go to activity monitor
        
        // then send data to database
        // then return to login page, preferably with new user hidden
    }
    
    func changeBorderColor(field: UITextField, color: UIColor) {
        field.layer.borderColor = color.cgColor
        field.layer.borderWidth = 1.0
        field.layer.cornerRadius = 5.0
    }
    
    @objc func checkForValidFirstName() {
        if isLetters(str: firstName.text!) {
            self.validFirstName = true
            changeBorderColor(field: firstName, color: UIColor.green)
        }
        else {
            self.validFirstName = false
            changeBorderColor(field: firstName, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    
    @objc func checkForValidLastName() {
        if isLetters(str: lastName.text!) {
            self.validLastName = true
            changeBorderColor(field: lastName, color: UIColor.green)
        }
        else {
            self.validLastName = false
            changeBorderColor(field: lastName, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
 
    
    @objc func checkForValidUsername() {
        if (isAlphanumeric(str: username.text!)) {
            self.validUsername = true
            changeBorderColor(field: username, color: UIColor.green)
        }
        else {
            self.validUsername = false
            changeBorderColor(field: username, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    
    @objc func checkForValidPassword() {
        if (isAlphanumeric(str: password.text!)) {
            self.validPassword = true
            changeBorderColor(field: password, color: UIColor.green)
        }
        else {
            self.validPassword = false
            changeBorderColor(field: password, color: UIColor.red)
        }
        if (confirmPassword.text != "") {
            checkForSamePassword()
        }
    }
    
    @objc func checkForSamePassword() {
        if confirmPassword.text == "" || confirmPassword.text != password.text {
            confirmPassword.backgroundColor = self.badColor
            saveButton.isEnabled = false
        }
        else {
            confirmPassword.backgroundColor = self.goodColor
            print(self.validFirstName)
            print(self.validLastName)
            print(self.validUsername)
            print(self.validPassword)
            saveButton.isEnabled = self.validFirstName && self.validLastName && self.validUsername && self.validPassword
        }
    }
    
    
    
    func isAlphanumeric(str: String) -> Bool { // Relative expression from https://stackoverflow.com/questions/35992800/check-if-a-string-is-alphanumeric-in-swift
        return !str.isEmpty && str.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    func isLetters(str: String) -> Bool{
        return !str.isEmpty && str.range(of: "[^a-zA-Z]", options: .regularExpression) == nil
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
