//
//  MatchedProfiles.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 14/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import Foundation

class Profiles {
    var uid : String = ""
    var name : String = ""
    var age : String = ""
    var gender : String = ""
    var email : String = ""
    var description : String = ""
    var profileImageURL : String = ""
    
    init() {
        
    }
    
    init(uid: String, dict: [String:Any]) {
        self.uid = uid
        self.name = dict["Name"] as? String ?? "No Name"
        self.age = dict["Age"] as? String ?? "No Age"
        self.gender = dict["Gender"] as? String ?? "No Gender"
        self.email = dict["Email"] as? String ?? "No Email"
        self.description = dict["Description"] as? String ?? "No Description"
        self.profileImageURL = dict["profilePicURL"] as? String ?? "No ProfilePicURL"
        
    }
}
