//
//  SelectImageViewController.swift
//  FaceIdentification
//
//  Created by NILESH_iOS on 22/06/18.
//  Copyright © 2018 iDev. All rights reserved.
//

import UIKit

protocol SelectImageViewControllerDelegate: class {
    func didSelectImage(_ image: UIImage)
}

class SelectImageViewController: UIViewController {

    var picker:UIImagePickerController?=UIImagePickerController()
    //var popover:UIModalPresentationPopover?=nil
    weak var delegate: SelectImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhotoBtnTapped(_ sender: UIButton) {
        openCamera()
    }
    
    @IBAction func galleryBtnTapped(_ sender: UIButton) {
        openGallary()
    }
    
    func openCamera()
    {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            //popover=UIModalPresentationPopover(contentViewController: picker)
            //popover!.presentPopoverFromRect(btnClickMe.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
}

extension SelectImageViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        //imageView.image=info[UIImagePickerControllerOriginalImage] as? UIImage
        var image: UIImage?
        
        if (info[UIImagePickerControllerEditedImage] != nil) {
            image = (info[UIImagePickerControllerEditedImage] as? UIImage)!
        } else {
            image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        }
        
        image = image?.fixedOrientation()
        
        delegate?.didSelectImage(image!)
        self.navigationController?.popViewController(animated: false)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picker cancel.")
        picker.dismiss(animated: true, completion: nil)
    }
}
