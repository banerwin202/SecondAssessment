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
    
    var ref                     : DatabaseReference!
    var currentProfile          : [Profiles] = []
    var profiles                : [Profiles] = []
    var matchedProfiles         : [String] = []
    var ageFilterProfiles       : [Profiles] = []
    var genderFilterProfiles    : [Profiles] = []
    var noFilterProfiles        : [Profiles] = []
    
    var currentUserAge      : Int = 0
    var currentUserGender   : String = ""
    var userIndex           : Int = 0
    var genderAgeMatchCount : Int = 0
    var matchProfileCount   : Int = 0
    
    @IBOutlet weak var candidateProfileImage: UIImageView!
    @IBOutlet weak var candidateName: UILabel!
    
    @IBOutlet weak var matchButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var noFilterButton: UIButton!
    
    //MARK: UIButton
    @IBAction func matchBtnTapped(_ sender: Any) {
        matchUser()
    }
    
    @IBAction func skipBtnTapped(_ sender: Any) {
        skipUser()
    }
    
    @IBAction func filterAgeBtnTapped(_ sender: Any) {
        profiles = ageFilterProfiles
        loadUser()
    }
    @IBAction func filterGenderBtnTapped(_ sender: Any) {
        profiles = genderFilterProfiles
        loadUser()
    }
    
    @IBAction func noFilterBtnTapped(_ sender: Any) {
        profiles = noFilterProfiles
        loadUser()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getAllUsers()
        getAllMatchedUsers()
        matchButton.isHidden = true
        skipButton.isHidden = true
    }
    
    func getAllMatchedUsers() {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        ref.child("UserMatch").child(currentUser).observe(.childAdded) { (snapshot) in
            let matchedUser = snapshot.key
            DispatchQueue.main.async {
                self.matchedProfiles.append(matchedUser)
            }
        }
    } // end of getAllMatchedUsers()
    
    func getAllUsers() {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        ref.child("User").child(currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String:Any] else {return}
            self.currentUserAge = Int(userDict["Age"] as? String ?? "") ?? 0
            self.currentUserGender = userDict["Gender"] as? String ?? ""
        }) // ref end
        
        ref.child("User").observe(.childAdded) { (snapshot) in
            guard let userDict = snapshot.value as? [String:Any] else {return}
            let allUserProfile = Profiles(uid: snapshot.key, dict: userDict)
            
            DispatchQueue.main.async {
                if snapshot.key != currentUser {    //load all user except currentUser
                    self.noFilterProfiles.append(allUserProfile)
                    
                    //filter only same age profile
                    if Int(allUserProfile.age) == self.currentUserAge { //save array for same age
                        self.ageFilterProfiles.append(allUserProfile)
                    }
                    
                    //filter only different gender profile
                    if allUserProfile.gender != self.currentUserGender { //save array for different gender
                        self.genderFilterProfiles.append(allUserProfile)
                    }
                }
            }
        } // ref end
    } // end of getAllUser()
    
    func loadUser() {
        userIndex = 0
        genderAgeMatchCount = 0
        matchButton.isHidden = false
        skipButton.isHidden = false
        
        for eachProfile in profiles {
            for eachMatchedProfile in matchedProfiles {
                if eachProfile.uid == eachMatchedProfile {
                    genderAgeMatchCount += 1
                }
            }
        }
        
        for eachMatchUser in matchedProfiles {
            if profiles[userIndex].uid == eachMatchUser {
                skipUser()
                return
            }
        }
        
        //        if matchedProfiles.count == noFilterProfiles.count {
        //            candidateName.text = "No Profile match you2"
        //            self.candidateProfileImage.image = UIImage(named: "")
        //            matchButton.isHidden = true
        //            skipButton.isHidden = true
        //        } else
        if profiles.count != 0 {
            candidateName.text = profiles[userIndex].name
            self.renderImage(profiles[userIndex].profileImageURL, cellImageView: self.candidateProfileImage)
            matchButton.isHidden = false
            skipButton.isHidden = false
        } else {
            //you can put alert action here
            candidateName.text = "No Profile match you3"
            self.candidateProfileImage.image = UIImage(named: "")
            matchButton.isHidden = true
            skipButton.isHidden = true
        }
        
    }
    
    func skipUser() {
        userIndex += 1
        
        if matchedProfiles.count == profiles.count {
            //        if matchProfileCount == profiles.count {
            candidateName.text = "No Profile match you4"
            self.candidateProfileImage.image = UIImage(named: "")
            matchButton.isHidden = true
            skipButton.isHidden = true
            return
        } else if userIndex == profiles.count && genderAgeMatchCount == profiles.count {
            userIndex = 0
            candidateName.text = "No Profile match you5"
            self.candidateProfileImage.image = UIImage(named: "")
            matchButton.isHidden = true
            skipButton.isHidden = true
            return
        } else if userIndex == profiles.count {
            userIndex = 0
            candidateName.text = profiles[userIndex].name
            self.renderImage(profiles[userIndex].profileImageURL, cellImageView: self.candidateProfileImage)
            
            return
        }
        
        for eachMatchUser in matchedProfiles {
            if profiles[userIndex].uid == eachMatchUser {
                skipUser()
                return
            }
        }
        candidateName.text = profiles[userIndex].name
        self.renderImage(profiles[userIndex].profileImageURL, cellImageView: self.candidateProfileImage)
    }
    
    func matchUser() {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let matchProfileUID = profiles[userIndex].uid
        matchProfileCount = 0
        ref.child("UserMatch").child(currentUser).child(matchProfileUID).setValue("true")
        userIndex += 1
        if userIndex == profiles.count {
            userIndex = 0
        }
        
        for eachProfile in profiles {
            for eachMatchedProfile in matchedProfiles {
                if eachProfile.uid == eachMatchedProfile {
                    matchProfileCount += 1
                    
                }
            }
        }
        
        if matchProfileCount == profiles.count-1 {
            candidateName.text = "No Profile match you6"
            self.candidateProfileImage.image = UIImage(named: "")
            matchButton.isHidden = true
            skipButton.isHidden = true
            return
        }
        
        for eachMatchUser in matchedProfiles {
            if profiles[userIndex].uid == eachMatchUser {
                skipUser()
                return
            }
        }
        
        candidateName.text = profiles[userIndex].name
        self.renderImage(profiles[userIndex].profileImageURL, cellImageView: self.candidateProfileImage)
        
    }
    
    /******************************************** ImageURL ********************************************/
    
    func renderImage(_ urlString: String, cellImageView: UIImageView) {
        
        guard let url = URL.init(string: urlString) else {return}
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let validData = data {
                let image = UIImage(data: validData)
                
                DispatchQueue.main.async {
                    cellImageView.image = image
                }
            }
        }
        task.resume()
    }
}
