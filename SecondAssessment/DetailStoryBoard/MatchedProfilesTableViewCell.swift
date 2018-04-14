//
//  MatchedProfilesTableViewCell.swift
//  SecondAssessment
//
//  Created by Ban Er Win on 14/04/2018.
//  Copyright © 2018 Ban Er Win. All rights reserved.
//

import UIKit

class MatchedProfilesTableViewCell: UITableViewCell {

    @IBOutlet weak var matchedImageView: UIImageView!
    
    @IBOutlet weak var matchedNameLabel: UILabel!
    @IBOutlet weak var matchedAgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
