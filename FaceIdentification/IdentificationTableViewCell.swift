//
//  IdentificationTableViewCell.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 26/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class IdentificationTableViewCell: UITableViewCell {

    @IBOutlet var faceImageView: UIImageView!
    @IBOutlet var firstLbl: UILabel!
    @IBOutlet var secondLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
