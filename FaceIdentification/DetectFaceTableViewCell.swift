//
//  DetectFaceTableViewCell.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 27/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

class DetectFaceTableViewCell: UITableViewCell {

    @IBOutlet var faceImageView: UIImageView!
    
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var thirdLabel: UILabel!
    @IBOutlet var forthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
