//
//  MatchedProfilesViewController.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 14/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MatchedProfilesViewController: UIViewController {
    
    var ref: DatabaseReference!
    var matchedProfiles : [Profiles] = []

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        observeMatchedProfiles()
    
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func observeMatchedProfiles() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("UserMatch").child(currentUserUID).observe(.childAdded) { (snapshot) in
            self.ref.child("User").child(snapshot.key).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let userDict = dataSnapshot.value as? [String:Any] else {return}
                let matchedUser = Profiles(uid: snapshot.key, dict: userDict)
                
                DispatchQueue.main.async {
                    self.matchedProfiles.append(matchedUser)
                    let indexPath = IndexPath(row: self.matchedProfiles.count - 1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            })
        }
    }

}

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

extension MatchedProfilesViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let selectedMatchID = self.matchedProfiles[indexPath.row]
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            ref.child("UserMatch").child(currentUserID).child(selectedMatchID.uid).removeValue { (error, deleteMatchUser) in
                
                if error != nil {
                    print("Error In Deleting TableView")
                }
                
                self.matchedProfiles.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedProfiles.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchedCell", for: indexPath) as? MatchedProfilesTableViewCell else {return UITableViewCell()}
        
        cell.matchedNameLabel.text = matchedProfiles[indexPath.row].name
        cell.matchedAgeLabel.text = matchedProfiles[indexPath.row].age
        
        let url = matchedProfiles[indexPath.row].profileImageURL
        if let a = cell.matchedImageView {
            renderImage(url, cellImageView: a)
        }
        
        return cell
    }
}

extension MatchedProfilesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         guard let vc = storyboard?.instantiateViewController(withIdentifier: "MatchedCandidateDetailScreenViewController") as? MatchedCandidateDetailScreenViewController else {return}
        
        let matchedUser = matchedProfiles[indexPath.row]
        
        vc.selectedMatchedProfiles = matchedUser
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
