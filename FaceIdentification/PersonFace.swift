//
//  PersonFace.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 21/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import Foundation
import ProjectOxfordFace

class PersonFace: NSObject {
    var faceId: String?
    var face: MPOFace?
    var image: UIImage?
}
