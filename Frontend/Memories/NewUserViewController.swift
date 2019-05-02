//
//  NewUserViewController.swift
//  Memories
//
//  Created by Eric on 4/28/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit
import AudioToolbox

class NewUserViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let badColor: UIColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.3)
    let goodColor: UIColor = UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.3)
    var validFirstName: Bool = false
    var validLastName: Bool = false
    var validUsername: Bool = false
    var validPassword: Bool = false
    var invalidUsernames: [String] = []
    
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let loadingAnimationView = UIView()
    
    func activityIndicator(title: String) {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        loadingAnimationView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        loadingAnimationView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 200, height: 46)
        loadingAnimationView.layer.cornerRadius = 15
        loadingAnimationView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:0.7)
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        loadingAnimationView.addSubview(activityIndicator)
        loadingAnimationView.addSubview(strLabel)
        self.view.addSubview(loadingAnimationView)
    }
    
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
        
        
        // then go to activity monitor
        
        // then send data to database
        // then return to login page, preferably with new user hidden
        self.doCreateNewUser()
    }
    
    
    func doCreateNewUser() { // gets called when login is touched up inside
        let fname = firstName.text
        let lname = lastName.text
        let usr = username.text
        let psw = password.text
        
        let url = URL(string: "https://fullstack-project-2.herokuapp.com/newUser/")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let param1 = "firstname=" + fname! + "&lastname=" + lname!
        let param2 = "&username=" + usr! + "&password=" + psw!
        let paramToSend = param1 + param2 // compiler requires this for some reason
        
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { // completionHandler code is implied
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                print(error as Any)
                self.newUserToDo()
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                self.newUserToDo()
                return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("unexpected response")
//                self.newUserToDo()
//                return
//            }
            
            // let code = httpResponse.statusCode // we may want to do something with this at some point
            
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with: responseData, options: [])
            }
            catch {
                print("error trying to convert data to JSON")
                print(String(data: responseData, encoding: String.Encoding.utf8) ?? "[data not convertible to string]")
                self.newUserToDo()
                return
            }
            
            guard let server_response = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                self.newUserToDo()
                return
            }
 
            
            guard let status = server_response["status"] as? String else {
                print("incorrect server_response format: no status field")
                self.newUserToDo()
                return
            }
            guard let message = server_response["message"] as? String else {
                print("incorrect server_response format: no message field")
                self.newUserToDo()
                return
            }
            
            if status == "false" { // then there was an error: code 406
                self.errorLabel.text = message
                self.errorLabel.textColor = UIColor.red
                self.newUserToDo()
                return
            }
            
            // otherwise all good
            
            
            DispatchQueue.main.async (
                execute: self.newUserDone
            )
        }
        
        task.resume()
    }
    
    
    
    func newUserToDo() {
        DispatchQueue.main.async {
            self.firstName.isEnabled = true
            self.lastName.isEnabled = true
            self.username.isEnabled = true
            self.password.isEnabled = true
            self.confirmPassword.isEnabled = true
            if self.errorLabel.text!.contains("username") { // crude way of determining if error involves username
                self.changeBorderColor(field: self.username, color: UIColor.red)
                self.invalidUsernames.append(self.username.text!)
            }
        }
       
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) // vibrates phone
    }
    
    func newUserDone() {
        DispatchQueue.main.async {
            self.firstName.isEnabled = false
            self.lastName.isEnabled = false
            self.username.isEnabled = false
            self.password.isEnabled = false
            self.confirmPassword.isEnabled = false
        }

        self.activityIndicator(title: "Securely creating user...")

        // Add a delay from: https://stackoverflow.com/questions/38031137/how-to-program-a-delay-in-swift-3
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.performSegue(withIdentifier: "saveNewUserSegue", sender: self)
        }
    }
    
    
    func changeBorderColor(field: UITextField, color: UIColor) {
        DispatchQueue.main.async {
            field.layer.borderColor = color.cgColor
            field.layer.borderWidth = 1.0
            field.layer.cornerRadius = 5.0
        }
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
        if (isAlphanumeric(str: username.text!) && !invalidUsernames.contains(username.text!)) {
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
