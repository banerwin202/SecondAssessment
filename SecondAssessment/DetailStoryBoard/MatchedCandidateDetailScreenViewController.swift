//
//  MatchedCandidateDetailScreenViewController.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 15/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MatchedCandidateDetailScreenViewController: UIViewController {
    
    var ref: DatabaseReference!
    var selectedMatchedProfiles : Profiles = Profiles()
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var LBLName: UILabel!
    @IBOutlet weak var LBLAge: UILabel!
    @IBOutlet weak var LBLGender: UILabel!
    @IBOutlet weak var LBLEmail: UILabel!
    @IBOutlet weak var LBLDescription: UILabel!
    
    @IBAction func unMatchBtnTapped(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        observeMatchedProfiles()

    }
    
    func observeMatchedProfiles() {
        let matchedProfileID = selectedMatchedProfiles.uid
        
        ref.child("User").child(matchedProfileID).observeSingleEvent(of: .value) { (snapshot) in
            guard let matchedUser = snapshot.value as? [String:Any] else {return}
            
            let profilePicURL = matchedUser["profilePicURL"] as? String ?? ""
            
            self.LBLName.text = matchedUser["Name"] as? String ?? ""
            self.LBLAge.text = matchedUser["Age"] as? String ?? ""
            self.LBLEmail.text = matchedUser["Email"] as? String ?? ""
            self.LBLGender.text = matchedUser["Gender"] as? String ?? ""
            self.LBLDescription.text = matchedUser["Description"] as? String ?? ""
            
            self.getImage(profilePicURL, self.profileImageView)
        }

            
        
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
