//
//  ViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 21/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class ViewController: UIViewController {

    var faces: [PersonFace]?
    //var results = [String: Any]()
    
    var results: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func faceDetect(image: UIImage) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        let data = UIImageJPEGRepresentation(image, 0.8)
        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: []) { (collection, error) in
            if error != nil {
                print("Detection Failed")
                return
            }
            
            self.faces?.removeAll()
            for face in collection! {
                let rect = CGRect(x: CGFloat(face.faceRectangle.left.floatValue), y: CGFloat(face.faceRectangle.top.floatValue), width: CGFloat(face.faceRectangle.width.floatValue), height: CGFloat(face.faceRectangle.height.floatValue))
                let croppedImage = image.crop(rect)
                let obj = PersonFace()
                obj.image = croppedImage
                obj.face = face
                self.faces?.append(obj)
            }
            
            if collection?.count == 0 {
                print("No face detected")
            }
            
        }
    }

    func identifyFaces(_ indexPath: IndexPath) {
        var faceIds = [String]()
        for obj in faces! {
            faceIds.append((obj.face?.faceId)!)
        }
        
        let group: PersonGroup? = Constant.groups[indexPath.row]
        
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.identify(withLargePersonGroupId: group?.groupId, faceIds: faceIds, maxNumberOfCandidates: (group?.groupPersons?.count)!) { (collection, error) in
            if error != nil {
                print("Failed in identification")
                return
            }
            
            self.results.removeAll()
            
            for idResult in collection! {
                let face = self.getFaceBy(idResult.faceId)
                for candidate in idResult.candidates {
                    let person = self.getPersonIn(group!, withPersonId: (candidate as! MPOCandidate).personId)
                    let array = ["face": face ?? "", "personName": person?.personName! ?? "", "confidence": (candidate as! MPOCandidate).confidence] as [String : Any]
                    self.results.append(array)
                }
            }
            
            if collection?.count == 0 {
                print("No record found")
            }
        }
    }
    
    func getFaceBy(_ faceId: String) -> PersonFace? {
        for face: PersonFace in faces! {
            if (face.face?.faceId == faceId) {
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
    
    var group = PersonGroup()
    
    func createNewGroup(_ groupName: String) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        let uuid = UUID().uuidString.lowercased()
        client.createLargePersonGroup(uuid, name: groupName, userData: nil) { (error) in
            if error != nil {
                print("Failed to create group")
                return
            }
            self.group.groupName = groupName
            self.group.groupId = uuid
            Constant.groups.append(self.group)
            /*
            if (_intension == INTENSION_ADD_PERSON) {
                MPOPersonFacesController * controller = [[MPOPersonFacesController alloc] initWithGroup:self.group];
                controller.needTraining = self.needTraining;
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                [CommonUtil showSimpleHUD:@"Group created" forController:self.navigationController];
            }*/
        }
    }
    
    func trainGroup() {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.trainLargePersonGroup(self.group.groupId) { (error) in
            if error != nil {
                print("failed in training group")
            }else {
                print("This group is trained")
            }
        }
    }
    
    func deletePersonFromGroup(_ index: Int) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        client.deletePerson(withLargePersonGroupId: self.group.groupId, personId: group.groupPersons![index].personId) { (error) in
            if error != nil {
                print("Failed in deleting this person")
                return
            }
            
            self.group.groupPersons?.remove(at: index)
        }
    }
    
    func updateGroup(_ groupName: String) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.updateLargePersonGroup(group.groupId, name: groupName, userData: nil) { (error) in
            if error != nil {
                print("Failed in updating group")
                return
            }
            
            self.group.groupName = groupName
            self.trainGroup()
        }
    }
    
    var person = GroupPerson()
    
    func createPerson(_ personName: String) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.createPerson(withLargePersonGroupId: group.groupId, name: personName, userData: nil) { (personResult, error) in
            if error != nil {
                print("Failed in creating person")
                return
            }
            self.person.personName = personName
            self.person.personId = personResult?.personId
            /*
            if (_intension == INTENSION_ADD_FACE) {
                [self chooseImage:nil];
            } else {
                [CommonUtil showSuccessHUD:@"Person created" forController:self.navigationController];
            }*/
        }
    }
    
    func updatePerson(_ personName: String) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.updatePerson(withLargePersonGroupId: group.groupId, personId: person.personId, name: personName, userData: nil) { (error) in
            if error != nil {
                print("Failed to update person")
                return
            }
            
            self.person.personName = personName
            
        }
    }
    
    func addPersonFace(image: UIImage, face: PersonFace) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        let data = UIImageJPEGRepresentation(image, 0.8)
        
        //client.addPersonFace(withLargePersonGroupId: group.groupId, personId: person.personId, url: <#T##String!#>, userData: <#T##String!#>, faceRectangle: <#T##MPOFaceRectangle!#>, completionBlock: <#T##((MPOAddPersistedFaceResult?, Error?) -> Void)!##((MPOAddPersistedFaceResult?, Error?) -> Void)!##(MPOAddPersistedFaceResult?, Error?) -> Void#>)
        
        client.addPersonFace(withLargePersonGroupId: group.groupId, personId: person.personId, data: data, userData: nil, faceRectangle: face.face?.faceRectangle) { (faceResult, error) in
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
    
    func deletePersonFace(_ index: Int) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: Constant.faceEndPoint, key: Constant.subscriptionKey)
        
        client.deletePersonFace(withLargePersonGroupId: group.groupId, personId: person.personId, persistedFaceId: person.faces![0].faceId) { (error) in
            if error != nil {
                print("Failed in deleting this face")
                return
            }
            
            self.person.faces?.remove(at: index)
        }
    }
}

extension UIImage {
    func crop(_ rect: CGRect) -> UIImage {
        let rectX = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        let imageRef = cgImage?.cropping(to: rectX)
        let result = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        return result

    }
    
    func fixedOrientation() -> UIImage? {
        
        guard imageOrientation != UIImageOrientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
}

struct Constant {
    static var groups = [PersonGroup]()
    //static var groupPersons = [GroupPerson]()
    //static var personFaces = [PersonFace]()
    static let subscriptionKey = "9cf360160541456ab94de37a0de3a34a"
    static let faceEndPoint = "https://southeastasia.api.cognitive.microsoft.com/face/v1.0"
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
