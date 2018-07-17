//
//  PersonGroup.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 21/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import Foundation

class PersonGroup: NSObject {
    var groupName: String?
    var groupPersons: [GroupPerson]?
    var groupId: String?
    
    override init() {
        super.init()
        groupPersons = [GroupPerson]()
        groupName = ""
    }
    
    convenience init(groupName name: String) {
        self.init()
        groupName = name
    }
}
