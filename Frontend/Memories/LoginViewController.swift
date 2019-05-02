//
//  LoginViewController.swift
//  Memories
//
//  Created by Eric on 4/28/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit
import AudioToolbox

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _login_button: UIButton!
    @IBOutlet weak var _newUserButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
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

        let preferences = UserDefaults.standard
        
        if (preferences.object(forKey: "username") != nil) {
            LoginDone()
        }

        
        _password.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)

        
        updateLoginButtonState()
    }
    
    // help from https://www.youtube.com/watch?v=y2hiaoaRBQ0
    @IBAction func LoginButton(_ sender: Any) {
        let username = _username.text
        let password = _password.text
        if (username == "") {
            changeBorderColor(field: _username, color: UIColor.red)
            return
        }
        else {
            changeBorderColor(field: _username, color: UIColor.clear)
        }
        
        if (password == "") {
            changeBorderColor(field: _username, color: UIColor.red)
            return
        }
        else {
            changeBorderColor(field: _username, color: UIColor.clear)
        }
        
        
        doLogin(username!, password!)
    }
    
    func changeBorderColor(field: UITextField, color: UIColor) {
        DispatchQueue.main.async {
            field.layer.borderColor = color.cgColor
            field.layer.borderWidth = 1.0
            field.layer.cornerRadius = 5.0
        }
    }
    
    
    func doLogin(_ user: String, _ psw: String) { // gets called when login is touched up inside
        _username.isEnabled = false // disables both buttons
        _password.isEnabled = false
        
        let url = URL(string: "https://fullstack-project-2.herokuapp.com/login/")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let paramToSend = "username=" + user + "&password=" + psw
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { // completionHandler code is implied
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                print(error as Any)
                self.LoginToDo()
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                self.LoginToDo()
                return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("unexpected response")
//                self.LoginToDo()
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
                self.LoginToDo()
                return
            }
            
            guard let server_response = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                self.LoginToDo()
                return
            }

            
            guard let status = server_response["status"] as? String else {
                print("incorrect server_response format: no status field")
                self.LoginToDo()
                return
            }
            guard let message = server_response["message"] as? String else {
                print("incorrect server_response format: no message field")
                self.LoginToDo()
                return
            }
            
            if status == "false" { // then there was an error: code 406
                DispatchQueue.main.async {
                    self.errorLabel.text = message
                    self.errorLabel.textColor = UIColor.red
                }
                self.LoginToDo()
                return
            }
            
            // otherwise all good
            
            
            let preferences = UserDefaults.standard
            preferences.set(user, forKey: "username") // updates userDefaults to this username
            DispatchQueue.main.async (
                execute: self.LoginDone
            )
        }
        
        task.resume()
    }
    
    
    func LoginToDo() {
        DispatchQueue.main.async {
            self._username.isEnabled = true
            self._password.isEnabled = true
        }
        changeBorderColor(field: _username, color: UIColor.red)
        changeBorderColor(field: _password, color: UIColor.red)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) // vibrates phone
    }
    
    func LoginDone() {
        DispatchQueue.main.async {
            self._username.isEnabled = false
            self._password.isEnabled = false
            self._login_button.isEnabled = false
        }
        changeBorderColor(field: _username, color: UIColor.green)
        changeBorderColor(field: _password, color: UIColor.green)
        
        self.activityIndicator(title: "Securely logging in...")
        
        // Add a delay from: https://stackoverflow.com/questions/38031137/how-to-program-a-delay-in-swift-3
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performSegue(withIdentifier: "userLoggedInSegue", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func goToNewUser(_ sender: UIButton) {
            performSegue(withIdentifier: "newUserSegue", sender: self)

    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateLoginButtonState()
    }

    
    //MARK: Private Methods
    @objc private func updateLoginButtonState(){
        // Disable the save button if the text field is empty.
        let username = _username.text ?? ""
        let password = _password.text ?? ""
        _login_button.isEnabled = !(username.isEmpty && password.isEmpty)
    }

}
