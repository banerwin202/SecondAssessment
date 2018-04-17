//
//  ViewController.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 12/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyProfileViewController: UIViewController {

    @IBOutlet weak var LBLName: UILabel!
    @IBOutlet weak var LBLAge: UILabel!
    @IBOutlet weak var LBLGender: UILabel!
    @IBOutlet weak var LBLEmail: UILabel!
    @IBOutlet weak var LBLDescription: UILabel!
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        observeUserProfile()
        
    }
    
    func observeUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("User").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let userDict = snapshot.value as? [String:Any] else {return}
            
            let profilePicURL = userDict["profilePicURL"] as? String ?? ""
            
            self.LBLName.text = userDict["Name"] as? String ?? ""
            self.LBLAge.text = userDict["Age"] as? String ?? ""
            self.LBLEmail.text = userDict["Email"] as? String ?? ""
            self.LBLGender.text = userDict["Gender"] as? String ?? ""
            self.LBLDescription.text = userDict["Description"] as? String ?? ""
            
            self.getImage(profilePicURL, self.profileImageView)
        }
        
    }

    
    //MARK: UIButton
    @IBAction func editBtnTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else {return}
        vc.nameString = LBLName.text!
        vc.ageString = LBLAge.text!
        vc.genderString = LBLGender.text!
        vc.emailString = LBLEmail.text!
        vc.descriptionString = LBLDescription.text!
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Get Image
    func getImage(_ urlString: String, _ imageView: UIImageView) {
        guard let url = URL.init(string: urlString) else {return}
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            if let validData = data {
                let image = UIImage(data: validData)
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
        task.resume()
    }
    

}

