//
//  FaceCollectionViewCell.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 26/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

protocol FaceCollectionViewCellDelegate: class {
    func didCheckbox(checked value: Bool, to index: Int)
}

class FaceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var faceImage: UIImageView!
    @IBOutlet var checkBtn: UIButton!
    
    weak var delegate: FaceCollectionViewCellDelegate?
    
    @IBAction func checkBtnTapped(_ sender: UIButton) {
        if sender.currentImage == #imageLiteral(resourceName: "unchecked") {
            sender.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            delegate?.didCheckbox(checked: true, to: sender.tag)
        }else {
            sender.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            delegate?.didCheckbox(checked: false, to: sender.tag)
        }
    }
}
