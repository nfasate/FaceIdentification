//
//  AddFacesToPersonViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class AddFacesToPersonViewController: UIViewController {

    @IBOutlet var faceCollectionView: UICollectionView!
    @IBOutlet var resultLbl: UILabel!
    
    var personGroup: PersonGroup?
    var person = GroupPerson()
    var faces: [PersonFace] = [PersonFace]()
    var image: UIImage?
    var isCheckedArray = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        faceDetect(image!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        
        var isChecked = false
        for isCheck in isCheckedArray {
            if isCheck == true {
                isChecked = isCheck
                break
            }
        }
        
        if isChecked {
            var count = faces.count
            for face in faces {
                addPersonFace(face)
                count = count - 1
                if count == 0 {
                   //self.navigationController?.popViewController(animated: true)
                }
            }
        }else {
            print("Please select atleast one face to add")
        }
    }

    func faceDetect(_ image: UIImage) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        let data = UIImageJPEGRepresentation(image, 0.8)
        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: []) { (collection, error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Detection Failed")
                self.resultLbl.text = error?.localizedDescription
                return
            }
            
            self.faces.removeAll()
            self.isCheckedArray.removeAll()
            
            for face in collection! {
                let rect = CGRect(x: CGFloat(face.faceRectangle.left.floatValue), y: CGFloat(face.faceRectangle.top.floatValue), width: CGFloat(face.faceRectangle.width.floatValue), height: CGFloat(face.faceRectangle.height.floatValue))
                let croppedImage = image.crop(rect)
                let obj = PersonFace()
                obj.image = croppedImage
                obj.face = face
                self.faces.append(obj)
                self.isCheckedArray.append(false)
            }
            
            if collection?.count == 0 {
                print("No face detected")
                self.resultLbl.text = "No face detected"
            }
            
            self.faceCollectionView.reloadData()
        }
    }
    
    func addPersonFace(_ face: PersonFace) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        let data = UIImageJPEGRepresentation(self.image!, 0.8)
        
        client.addPersonFace(withLargePersonGroupId: personGroup?.groupId, personId: person.personId, data: data, userData: nil, faceRectangle: face.face?.faceRectangle) { (faceResult, error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Failed in adding face")
                return
            }
            
            face.faceId = faceResult?.persistedFaceId
            self.person.faces?.append(face)
            
            //[self.detectedFaces removeObject:face];
            //*self.needTraining = YES;
        }
    }
}

extension AddFacesToPersonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "faceCell", for: indexPath) as! FaceCollectionViewCell
        cell.faceImage.image = faces[indexPath.row].image
        cell.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        cell.checkBtn.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension AddFacesToPersonViewController: FaceCollectionViewCellDelegate {
    func didCheckbox(checked value: Bool, to index: Int) {
        isCheckedArray[index] = value
    }
}
