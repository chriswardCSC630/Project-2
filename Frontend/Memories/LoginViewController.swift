//
//  LoginViewController.swift
//  Memories
//
//  Created by Eric on 4/28/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var _login_button: UIButton!
    @IBOutlet weak var _newUserButton: UIButton!
    
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
        
        if (preferences.object(forKey: "session") != nil) {
            LoginDone()
        }
        else {
            LoginToDo()
        }
        
        _password.addTarget(self, action: #selector(updateLoginButtonState), for: .editingChanged)

        
        updateLoginButtonState()
    }
    
    // help from https://www.youtube.com/watch?v=y2hiaoaRBQ0
    @IBAction func LoginButton(_ sender: Any) {
        let username = _username.text
        let password = _password.text
        if (username == "" || password == "") {
            print("invalid username and/or password")
            return
        }
        doLogin(username!, password!)
    }
    
    func doLogin(_ user: String, _ psw: String) { // gets called when login is touched up inside
//        _username.isEnabled = false // disables both buttons
//        _password.isEnabled = false
        
        let url = URL(string: "http://www.kaleidosblog.com/tutorial/login/api/login")
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
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with: responseData, options: [])
            }
            catch {
                print("error trying to convert data to JSON")
                print(String(data: responseData, encoding: String.Encoding.utf8) ?? "[data not convertible to string]")
                return
            }
            
            guard let server_response = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                return
            }
            
            if let data_block = server_response["data"] as? NSDictionary {
                if let session_data = data_block["session"] as? String {
                    let preferences = UserDefaults.standard
                    preferences.set(session_data, forKey: "session") // updates userDefaults to this session
                    DispatchQueue.main.async (
                        execute: self.LoginDone
                    )
                }
            }
        }
        
        task.resume()
        self.LoginDone()
    }
    
//    func invalidRequest(data: Data?, response: URLResponse?, error: Error?, m: String) {
//        LoginToDo()
//        print(m)
//        if data == nil {
//            print("no data")
//        }
//        else {
//            print(data)
//        }
//        if response == nil {
//            print("no response")
//        }
//        else {
//            print(response)
//        }
//        if error == nil {
//            print("no error")
//        }
//        else {
//            print(error)
//        }
//
//    }
    
    func LoginToDo() {
        _username.isEnabled = true
        _password.isEnabled = true
    }
    
    func LoginDone() {
        _username.isEnabled = false
        _password.isEnabled = false
        _login_button.isEnabled = false
        
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
