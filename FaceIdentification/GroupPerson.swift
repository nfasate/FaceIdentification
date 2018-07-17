//
//  GroupPerson.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 21/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import Foundation

class GroupPerson: NSObject {
    var personId: String?
    var personName: String?
    var faces: [PersonFace]? = [PersonFace]()
}
