//
//  IdentificationViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class IdentificationViewController: UIViewController {

    @IBOutlet var selectImageView: UIImageView!
    @IBOutlet var groupListTableView: UITableView!
    @IBOutlet var resultTableView: UITableView!
    @IBOutlet var selectImageBaseView: UIView!
    
    var faces: [PersonFace]? = [PersonFace]()
    var results: [[String:Any]] = []
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupListTableView.tableFooterView = UIView()
        resultTableView.tableFooterView = UIView()
        getGroup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let screenSize: CGRect = selectImageBaseView.bounds
        //let myView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width - 10, height: 10))
        //myView.backgroundColor = UIColor.black
        //self.selectImageBaseView.addSubview(myView)
        self.groupListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func identifyBtnTapped(_ sender: UIButton) {
        if selectedIndexPath != nil {
            identifyFaces(selectedIndexPath!)
        }else {
            print("Please select person group")
        }
    }
    
    @IBAction func selectImageBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectImageController = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as! SelectImageViewController
        selectImageController.delegate = self
        self.navigationController?.pushViewController(selectImageController, animated: true)
    }
    
    func identifyFaces(_ indexPath: IndexPath) {
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        var faceIds = [String]()
        for obj in faces! {
            faceIds.append((obj.face?.faceId)!)
        }
        
        if faceIds.count > 10 {
            
        }
        
        let group: PersonGroup? = Constant.groups[indexPath.row]
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.identify(withLargePersonGroupId: group?.groupId, faceIds: faceIds, maxNumberOfCandidates: (group?.groupPersons?.count)!) { (collection, error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Failed in identification")
                return
            }
            
            self.results.removeAll()
            
            for idResult in collection! {
                let face = self.getFaceBy(idResult.faceId)
                
                if idResult.candidates.count == 0 {
                    let array = ["face": face ?? "", "personName": "", "confidence": ""] as [String : Any]
                    self.results.append(array)
                }
                
                for candidate in idResult.candidates {
                    let person = self.getPersonIn(group!, withPersonId: (candidate as! MPOCandidate).personId)
                    let array = ["face": face ?? "", "personName": person?.personName! ?? "", "confidence": (candidate as! MPOCandidate).confidence] as [String : Any]
                    self.results.append(array)
                }
            }
            
            self.resultTableView.reloadData()
            
            if collection?.count == 0 {
                print("No record found")
            }
        }
    }
    
    func faceDetect(image: UIImage) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        let data = UIImageJPEGRepresentation(image, 0.8)
        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: []) { (collection, error) in
            UIViewController.removeSpinner(spinner: sv)
            if error != nil {
                print("Detection Failed")
                return
            }
            
            self.faces?.removeAll()
            for face in collection! {
                let rect = CGRect.init(x: face.faceRectangle.left.doubleValue, y: face.faceRectangle.top.doubleValue, width: face.faceRectangle.width.doubleValue, height: face.faceRectangle.height.doubleValue)
                print(rect)
                let croppedImage = image.crop(rect)
                let obj = PersonFace()
                //self.selectImageView.image = croppedImage
                
                //self.selectImageView.isHidden = true
                
                //let myView = UIView(frame: CGRect(x: face.faceRectangle.left.doubleValue, y: face.faceRectangle.top.doubleValue, width: face.faceRectangle.width.doubleValue, height: face.faceRectangle.height.doubleValue))
                //myView.backgroundColor = UIColor.black
                //self.selectImageBaseView.addSubview(myView)
                
                obj.image = croppedImage
                obj.face = face
                obj.faceId = face.faceId
                self.faces?.append(obj)
            }
            
            if collection?.count == 0 {
                print("No face detected")
            }
            
            self.resultTableView.reloadData()
        }
    }
    
    func getFaceBy(_ faceId: String) -> PersonFace? {
        for face: PersonFace in faces! {
            if (face.faceId == faceId) {
                return face
            }
        }
        return nil
    }
    
    func getPersonIn(_ group: PersonGroup, withPersonId personId: String) -> GroupPerson? {
        for person: GroupPerson in group.groupPersons! {
            if (person.personId == personId) {
                return person
            }
        }
        return nil
    }
    
    var svX: UIView?
    
    func getGroup() {
        svX = UIViewController.displaySpinner(onView: self.view)
        Constant.groups.removeAll()
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        let personGroupId = "he73d319-bf84-4243-9beb-4aae88825e59"
        client.getLargePersonGroup(personGroupId) { (largePersonGroup, error) in
            if error != nil {
                UIViewController.removeSpinner(spinner: self.svX!)
                print("Large person group ID is invalid \(error.debugDescription)")
                return
            }
            
            if let personGroup = largePersonGroup {
                let groupName = personGroup.name
                let groupId = personGroup.largePersonGroupId
                let group = PersonGroup(groupName: groupName!)
                group.groupId = groupId
                Constant.groups.append(group)
            }else {
                print("Not available")
            }
            self.getGroupPerson(0)
            self.groupListTableView.reloadData()
        }
    }
    
    func getGroupPerson(_ pIndex: Int) {
        
        if pIndex == Constant.groups.count {
            UIViewController.removeSpinner(spinner: self.svX!)
            return
        }
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        client.listPersons(withLargePersonGroupId: Constant.groups[pIndex].groupId) { (groupPersons, error) in
            if error != nil {
                UIViewController.removeSpinner(spinner: self.svX!)
                print("list not fetch")
                return
            }
            Constant.groups[pIndex].groupPersons?.removeAll()
            for groupPerson in groupPersons! {
                let person = GroupPerson()
                person.personName = groupPerson.name
                person.personId = groupPerson.personId
                for faceId in groupPerson.persistedFaceIds {
                    let face = PersonFace()
                    face.faceId = faceId as? String
                    person.faces?.append(face)
                }
                Constant.groups[pIndex].groupPersons?.append(person)
            }
            
            self.getGroupPerson(pIndex+1)
        }
    }
}

extension IdentificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == groupListTableView {
            return Constant.groups.count
        }else if tableView == resultTableView {
            if results.count == 0 {
                return (faces?.count)!
            }
            return (results.count)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == groupListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "personGroupCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = Constant.groups[indexPath.row].groupName
            return cell
        }else if tableView == resultTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "identityCell", for: indexPath) as! IdentificationTableViewCell
            if results.count == 0 {
                cell.faceImageView.image = faces![indexPath.row].image
                cell.firstLbl.text = ""
                cell.secondLbl.text = ""
            }else {
                let resultArr = results[indexPath.row]
                cell.faceImageView.image = (resultArr["face"] as! PersonFace).image
                
                if let personName = resultArr["personName"] as? String, personName != "" {
                    cell.firstLbl.text = "Person Name: \(personName)"
                    cell.secondLbl.text = "Confidence: \(String(describing: resultArr["confidence"]!))"
                }else {
                    cell.firstLbl.text = "Face not identify"
                    cell.secondLbl.isHidden = true
                }
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == groupListTableView {
            selectedIndexPath = indexPath
        }
    }
}

extension IdentificationViewController: SelectImageViewControllerDelegate {
    func didSelectImage(_ image: UIImage) {
        selectImageView.image = image
        faceDetect(image: image)
    }
}

class ShapeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawRectangle(rect: rect)
    }
    
    func drawRectangle(rect: CGRect) {
        let center = CGPoint(x: rect.origin.x, y: rect.origin.y)
        let rectangleWidth:CGFloat = rect.size.width
        let rectangleHeight:CGFloat = rect.size.height
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        //4
        ctx.addRect(CGRect(x: center.x - (0.5 * rectangleWidth), y: center.y - (0.5 * rectangleHeight), width: rectangleWidth, height: rectangleHeight))
        ctx.setLineWidth(10)
        ctx.setStrokeColor(UIColor.gray.cgColor)
        ctx.strokePath()
        
        //5
        ctx.setFillColor(UIColor.green.cgColor)
        
        ctx.addRect(CGRect(x: center.x - (0.5 * rectangleWidth), y: center.y - (0.5 * rectangleHeight), width: rectangleWidth, height: rectangleHeight))
        
        ctx.fillPath()
    }
}
