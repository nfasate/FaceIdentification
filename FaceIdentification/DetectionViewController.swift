//
//  DetectionViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class DetectionViewController: UIViewController {

    @IBOutlet var selectImageView: UIImageView!
    @IBOutlet var resultTableView: UITableView!
    
    var faces: [PersonFace]? = [PersonFace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func detectBtnTapped(_ sender: UIButton) {
        faceDetect(image: selectImageView.image!)
    }
    
    @IBAction func selectImageBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectImageController = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as! SelectImageViewController
        selectImageController.delegate = self
        self.navigationController?.pushViewController(selectImageController, animated: true)
    }
    
    func faceDetect(image: UIImage) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        let data = UIImageJPEGRepresentation(image, 0.8)
        
        
        //client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [MPOFaceAttributeTypeGender, MPOFaceAttributeTypeAge, MPOFaceAttributeTypeHair, MPOFaceAttributeTypeFacialHair, MPOFaceAttributeTypeMakeup, MPOFaceAttributeTypeEmotion, MPOFaceAttributeTypeOcclusion, MPOFaceAttributeTypeExposure, MPOFaceAttributeTypeHeadPose, MPOFaceAttributeTypeAccessories], completionBlock: { collection, error in
        
        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [MPOFaceAttributeTypeGender.rawValue, MPOFaceAttributeTypeAge.rawValue, MPOFaceAttributeTypeHair.rawValue, MPOFaceAttributeTypeEmotion.rawValue]) { (collection, error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Detection Failed")
                return
            }
            if self.faces != nil {
                self.faces?.removeAll()
            }
            for face in collection! {
                let rect = CGRect(x: CGFloat(face.faceRectangle.left.floatValue), y: CGFloat(face.faceRectangle.top.floatValue), width: CGFloat(face.faceRectangle.width.floatValue), height: CGFloat(face.faceRectangle.height.floatValue))
                let croppedImage = image.crop(rect)
                let obj = PersonFace()
                obj.image = croppedImage
                obj.face = face
                self.faces?.append(obj)
                print("facelandmarks: \(face.faceLandmarks.debugDescription)")
            }
            
            if collection?.count == 0 {
                print("No face detected")
            }
            
            self.resultTableView.reloadData()
            
        }
    }
}

extension DetectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (faces?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detectCell", for: indexPath) as! DetectFaceTableViewCell
        cell.faceImageView.image = faces![indexPath.row].image
        cell.firstLabel.text = "Gender: " + (faces![indexPath.row].face?.attributes.gender)!
        cell.secondLabel.text = "Age: " + (faces![indexPath.row].face?.attributes.age.stringValue)!
        cell.thirdLabel.text = "Hair: " + (faces![indexPath.row].face?.attributes.hair.hair)!
        cell.forthLabel.text = "Emotion: " + (faces![indexPath.row].face?.attributes.emotion.mostEmotion)!
        
        return cell
    }
}

extension DetectionViewController: SelectImageViewControllerDelegate {
    func didSelectImage(_ image: UIImage) {
        selectImageView.image = image
    }
}
