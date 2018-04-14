//
//  SignUpViewController.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 12/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref : DatabaseReference!
    let imagePicker = UIImagePickerController()
    
    var nameString : String = ""
    var ageString: String = ""
    var genderString: String = ""
    var emailString: String = ""
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var updateButtonTapped: UIButton!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(findImageButtonTapped))
            profileImageView.addGestureRecognizer(tap)
        }
    }
    
    //MARK: UIButton
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBAction func createBtnTapped(_ sender: Any) {
               signUpUser()
    }
    
    @IBAction func updateBtnTapped(_ sender: Any) {
            updateUserDetails()
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setupAddTargetIsNotEmptyTextFields()
        imagePicker.delegate = self
        
        if Auth.auth().currentUser == nil {
            createButton.isHidden = false
            updateButton.isHidden = true
        } else {
            createButton.isHidden = true
            updateButton.isHidden = false
            
            nameTextField.text = nameString
            ageTextField.text = ageString
            genderTextField.text = genderString
            emailTextField.text = emailString
        }
        
    }
    
    //Disables Create Button if info are not filled up
    func setupAddTargetIsNotEmptyTextFields() {
        createButton.isEnabled = false
        emailTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                 for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                    for: .editingChanged)
        ageTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                     for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                    for: .editingChanged)
        genderTextField.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                    for: .editingChanged)
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard
            let email = emailTextField.text, !email.isEmpty,
            let name = nameTextField.text, !name.isEmpty,
            let age = ageTextField.text, !age.isEmpty,
            let gender = genderTextField.text, !gender.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else
        {
            self.createButton.isEnabled = false
            return
        }
        // enable okButton if all conditions are met
        createButton.isEnabled = true
    }
    
    @objc func findImageButtonTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadToStorage(_ image: UIImage) {
        let storageRef = Storage.storage().reference()
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.child(userID).child("profilePic").putData(imageData, metadata: metaData) { (meta, error) in
            
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadURL = meta?.downloadURL()?.absoluteString {
                self.ref.child("User").child(userID).child("profilePicURL").setValue(downloadURL)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.image = pickedImage
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func signUpUser() {
        guard let email = emailTextField.text,
            let age = ageTextField.text,
            let name = nameTextField.text,
            let userDescription = descriptionTextField.text,
            let gender = genderTextField.text,
            let password = passwordTextField.text else {return}
        
        if !email.contains("@") {
            //show error //if email not contain @
            showAlert(withTitle: "Invalid Email format", message: "Please input valid Email")
        } else if password.count < 6 {
            //show error
            showAlert(withTitle: "Invalid Password", message: "Password must contain 6 characters")
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                //ERROR HANDLING
                if let validError = error {
                    self.showAlert(withTitle: "Error", message: validError.localizedDescription)
                }
                
                //HANDLE SUCESSFUL CREATION OF USER
                if let validUser = user {
                    self.ageTextField.text = ""
                    self.emailTextField.text = ""
                    self.nameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.descriptionTextField.text = ""
                    self.genderTextField.text = ""
                    
                    if let image = self.profileImageView.image {
                        self.uploadToStorage(image)
                    }
                    
                    let userPost: [String:Any] = ["Age": age, "Email": email, "Name" : name, "Description" : userDescription, "Gender": gender]
                    
                    self.ref.child("User").child(validUser.uid).setValue(userPost)
                    
                    //                    let sb = UIStoryboard(name: "HospitalDetail", bundle: Bundle.main)
                    guard let navVC = self.storyboard?.instantiateViewController(withIdentifier: "userTabBarController") as? UITabBarController else {return}
                    
                    self.present(navVC, animated: true, completion: nil)
                    print("sign up method successful")
                }
            })
        }
    }
    
    func updateUserDetails() {
        guard let email = emailTextField.text,
            let age = ageTextField.text,
            let name = nameTextField.text,
            let gender = genderTextField.text,
            let userDescription = descriptionTextField.text else {return}
        
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
    
        
        let userPost: [String:Any] = ["Age": age, "Email": email, "Name" : name, "Description" : userDescription, "Gender" : gender]
        
        self.ref.child("User").child(currentUser).updateChildValues(userPost)
        
        if let image = self.profileImageView.image {
            self.uploadToStorage(image)
        }
    }
    
}



