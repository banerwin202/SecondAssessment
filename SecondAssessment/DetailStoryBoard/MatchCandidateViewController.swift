//
//  MatchCandidateViewController.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 14/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MatchCandidateViewController: UIViewController {
    
    var ref: DatabaseReference!
    var profiles : [Profiles] = []

    @IBOutlet weak var candidateProfileImage: UIImageView!
    @IBOutlet weak var candidateName: UILabel!
    
    @IBOutlet weak var matchButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var noFilterButton: UIButton!
    
    //MARK: UIButton
    @IBAction func matchBtnTapped(_ sender: Any) {
    }
    
    @IBAction func skipBtnTapped(_ sender: Any) {
    }
    
    @IBAction func filterAgeBtnTapped(_ sender: Any) {
    }
    
    @IBAction func filterGenderBtnTapped(_ sender: Any) {
    }
    
    @IBAction func noFilterBtnTapped(_ sender: Any) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
       
    }

    func loadAllUsers() {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        ref.child("Users").observe(.childAdded) { (snapshot) in
        guard let userDict = snapshot.value as? [String:Any] else {return}
            let name = userDict["Name"] as? String? ?? ""
            let age = userDict["Age"] as? String ?? ""
            let gender = userDict["Gender"] as? String ?? ""
            let email = userDict["Email"] as? String ?? ""
            let description = userDict["Description"] as? String ?? ""
            
            
            
            
            
        }
    
    }

}
