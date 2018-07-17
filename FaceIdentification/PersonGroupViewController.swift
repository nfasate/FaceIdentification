//
//  PersonGroupViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class PersonGroupViewController: UIViewController {

    @IBOutlet var groupNameTxt: UITextField!
    @IBOutlet var personCollectionView: UICollectionView!
    
    var personGroup: PersonGroup?
    var isCreate = true
    var isGroupCreate = false
    var pIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let onTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        onTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(onTap)
        if isCreate == false {
            //getGroupPerson()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if personGroup != nil {
            groupNameTxt.text = personGroup?.groupName
        }
        personCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        if groupNameTxt.text == "" || (groupNameTxt.text?.isEmpty)! {
            showAlert("Please eneter group name", message: "")
            print("Please enter group name")
            return
        }
        
        if isGroupCreate {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if isCreate {
            createNewGroup(groupNameTxt.text!, isDismiss: true)
        }else {
            updateGroup(groupNameTxt.text!)
        }
    }
    
    @IBAction func addPersonBtnTapped(_ sender: UIButton) {
        if pIndex == Constant.groups.count {
            if groupNameTxt.text == "" || (groupNameTxt.text?.isEmpty)! {
                showAlert("Please eneter group name", message: "")
                print("Please enter group name")
                return
            }
            createNewGroup(groupNameTxt.text!, isDismiss: false)
        }else {
            presentPersonViewController(true, index: -1)
        }
    }
    
    func presentPersonViewController(_ isCreate: Bool, index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PersonViewController") as! PersonViewController
        controller.personGroup = personGroup
        controller.isCreate = isCreate
        controller.isPersonCreate = !isCreate
        if index != -1 {
            controller.person = (Constant.groups[self.pIndex].groupPersons?[index])! //Constant.groupPersons[index]
        }
        controller.pIndex = pIndex
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func dismissKeyboard() {
        groupNameTxt.endEditing(true)
    }
    
    func createNewGroup(_ groupName: String, isDismiss: Bool) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        //let uuid = UUID().uuidString.lowercased()
        let uuid = "he73d319-bf84-4243-9beb-4aae88825e59"
        client.createLargePersonGroup(uuid, name: groupName, userData: nil) { (error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Failed to create group")
                self.showAlert("Failed to create group", message: (error?.localizedDescription)!)
                return
            }
            self.personGroup = PersonGroup()
            self.personGroup?.groupName = groupName
            self.personGroup?.groupId = uuid
            Constant.groups.append(self.personGroup!)
            /*
             if (_intension == INTENSION_ADD_PERSON) {
             MPOPersonFacesController * controller = [[MPOPersonFacesController alloc] initWithGroup:self.group];
             controller.needTraining = self.needTraining;
             [self.navigationController pushViewController:controller animated:YES];
             } else {
             [CommonUtil showSimpleHUD:@"Group created" forController:self.navigationController];
             }*/
            self.isGroupCreate = true
            if isDismiss {
                self.navigationController?.popViewController(animated: true)
            }else {
                self.presentPersonViewController(true, index: -1)
            }
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            
        }
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateGroup(_ groupName: String) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.updateLargePersonGroup(personGroup?.groupId, name: groupName, userData: nil) { (error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Failed in updating group")
                self.showAlert("failed in updating group", message: (error?.localizedDescription)!)
                return
            }
            
            self.personGroup?.groupName = groupName
            self.trainGroup()
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getGroupPerson() {
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        client.listPersons(withLargePersonGroupId: personGroup?.groupId) { (groupPersons, error) in
            if error != nil {
                print("list not fetch")
                self.showAlert("failed in fetching group person", message: (error?.localizedDescription)!)
                return
            }
            //Constant.groupPersons.removeAll()
            Constant.groups[self.pIndex].groupPersons?.removeAll()
            for groupPerson in groupPersons! {
                let person = GroupPerson()
                person.personName = groupPerson.name
                person.personId = groupPerson.personId
                for faceId in groupPerson.persistedFaceIds {
                    let face = PersonFace()
                    face.faceId = faceId as? String
                    person.faces?.append(face)
                }
                //Constant.groupPersons.append(person)
                Constant.groups[self.pIndex].groupPersons?.append(person)
            }
            
//            for xPerson in Constant.groups[self.pIndex].groupPersons { //Constant.groupPersons {
//                for xFace in xPerson.faces! {
//                    self.getPersonFaces(person: xPerson, face: xFace)
//                }
//            }
            
            self.personCollectionView.reloadData()
        }
    }
    
    func getPersonFaces(person: GroupPerson, face: PersonFace) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.getPersonFace(withLargePersonGroupId: personGroup?.groupId, personId: person.personId, persistedFaceId: face.faceId) { (personFace, error) in
            if error != nil {
                print("Face not detected")
                return
            }
            //print("\(String(describing: personFace?.userData))")
        }
        
    }
    
    func trainGroup() {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.trainLargePersonGroup(personGroup?.groupId) { (error) in
            if error != nil {
                print("failed in training group")
                self.showAlert("failed in training group", message: (error?.localizedDescription)!)
            }else {
                print("This group is trained")
            }
        }
    }
}

extension PersonGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return Constant.groupPersons.count
        if pIndex == Constant.groups.count {
            return 0
        }
        return (Constant.groups[self.pIndex].groupPersons?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personCell", for: indexPath) as! GroupPersonCollectionViewCell
        //Constant.groupPersons[indexPath.row].faces?.count
        if let count = Constant.groups[self.pIndex].groupPersons?[indexPath.row].faces?.count, count > 0, let Image = Constant.groups[self.pIndex].groupPersons?[indexPath.row].faces?[0].image {
            cell.imageView.image = Image //Constant.groupPersons[indexPath.row].faces?[0].image
        }
        cell.nameLable.text =  Constant.groups[self.pIndex].groupPersons?[indexPath.row].personName //Constant.groupPersons[indexPath.row].personName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentPersonViewController(false, index: indexPath.row)
    }
}
