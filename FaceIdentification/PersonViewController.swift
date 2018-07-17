//
//  PersonViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class PersonViewController: UIViewController {

    @IBOutlet var personNameTxt: UITextField!
    @IBOutlet var faceCollectionView: UICollectionView!
    
    var personGroup: PersonGroup?
    var person = GroupPerson()
    var isCreate = false
    var pIndex = 0
    var isPersonCreate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let onTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        onTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(onTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isCreate == false {
            personNameTxt.text = person.personName
        }
        
        faceCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        personNameTxt.endEditing(true)
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        if (personNameTxt.text?.isEmpty)! || personNameTxt.text == "" {
            print("Please enter person name")
            showAlert("Please eneter person name", message: "")
            return
        }
        
        if isPersonCreate {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if isCreate {
            createPerson(personNameTxt.text!)
        }else {
            updatePerson(personNameTxt.text!)
        }
    }
    
    @IBAction func addFaceBtnTapped(_ sender: UIButton) {
        if (personNameTxt.text?.isEmpty)! || personNameTxt.text == "" {
            print("Please enter person name")
            showAlert("Please eneter person name", message: "")
            return
        }
        
        if isPersonCreate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let selectImageController = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as! SelectImageViewController
            selectImageController.delegate = self
            self.navigationController?.pushViewController(selectImageController, animated: true)
        }else {
            createPerson(personNameTxt.text!)
        }
    }
    
    func createPerson(_ personName: String) {
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.createPerson(withLargePersonGroupId: personGroup?.groupId, name: personName, userData: nil) { (personResult, error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Failed in creating person")
                self.showAlert("Failed in creating person", message: (error?.localizedDescription)!)
                return
            }
            self.person.personName = personName
            self.person.personId = personResult?.personId
            
            //Constant.groupPersons.append(self.person)
            Constant.groups[self.pIndex].groupPersons?.append(self.person)
            
            /*
             if (_intension == INTENSION_ADD_FACE) {
             [self chooseImage:nil];
             } else {
             [CommonUtil showSuccessHUD:@"Person created" forController:self.navigationController];
             }*/
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updatePerson(_ personName: String) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.updatePerson(withLargePersonGroupId: personGroup?.groupId, personId: person.personId, name: personName, userData: nil) { (error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Failed to update person")
                self.showAlert("Failed in update person", message: (error?.localizedDescription)!)
                return
            }
            
            self.person.personName = personName
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func presentAddFaceViewController(_ image: UIImage) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddFacesToPersonViewController") as! AddFacesToPersonViewController
        controller.person = person
        controller.personGroup = personGroup
        controller.image = image
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            
        }
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension PersonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = person.faces?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personFaceCell", for: indexPath) as! PersonFaceCollectionViewCell
        if let image = person.faces?[indexPath.row].image {
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension PersonViewController: SelectImageViewControllerDelegate {
    func didSelectImage(_ image: UIImage) {
        presentAddFaceViewController(image)
    }
}
