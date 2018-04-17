//
//  ViewController.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 12/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    var ref : DatabaseReference!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        signInButtonTapped()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        userChecking()
        disablesSignInBtn()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func disablesSignInBtn() {
        signInButton.isEnabled = false
        
        loginTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty(sender:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty(sender:)), for: .editingChanged)
        
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let login = loginTextField.text, !login.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else
        {
            self.signInButton.isEnabled = false
            return
        }
        // enable okButton if all conditions are met
        signInButton.isEnabled = true
    }
    
    func userChecking () {
        ref.child("User").observe(.childAdded) { (snapshot) in
            guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
            
            if Auth.auth().currentUser != nil && currentUserUID == snapshot.key {
                //                let sb = UIStoryboard(name: "HospitalDetail", bundle: Bundle.main)
                
                guard let navVC = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarController") as? UITabBarController else {return}
                
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    func signInButtonTapped() {
        var userIsSignedIn : Bool = false
        
        guard let email = loginTextField.text,
            let password = passwordTextField.text else {return}
        
        ref.child("User").observe(.value) { (snapshot) in
            
            if let dict = snapshot.value as? [String:Any] {
                
                for id in dict {
                    if let idValues = id.value as? [String:Any],
                        let emailValue = idValues["Email"] as? String {
                        
                        if email == emailValue {
                            userIsSignedIn = true
                            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                                if let validError = error {
                                    self.showAlert(withTitle: "Error", message: validError.localizedDescription)
                                    
                                }
                                
                                if user != nil {
                                    self.loginTextField.text = ""
                                    self.passwordTextField.text = ""
                                
                                    guard let navVC = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarController") as? UITabBarController else {return}
                                    self.present(navVC, animated: true, completion: nil)
                                    
                                }
                            }
                        }
                    }
                }
                
                if userIsSignedIn == false {
                    self.showAlert(withTitle: "Error", message: "Please sign in with an existing  account")
                }
            }
        }
    }
    
    
}

