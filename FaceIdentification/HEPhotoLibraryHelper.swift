//
//  HEPhotoLibraryHelper.swift
//  HeroEyez-ClassRoom
//
//  Created by Nilesh Fasate on 14/11/16.
//  Copyright © 2016 Delaplex Softwares. All rights reserved.
//

import UIKit
import Photos
/// HEPhotoLibraryHelper class used for save and fetch images/videos from photo library.
class HEPhotoLibraryHelper: NSObject
{
    //MARK:- Variables    
    /// Array object of images
    static var imageItems = [AnyObject]()
    /// Evidence folder name for Photos
    static var albumName = Macros.Constants.evidenceFolderName
    /// Asset collection object to store asset data
    static var assetCollection: PHAssetCollection = PHAssetCollection()
    /// Store photo asset data
    static var photosAsset: PHFetchResult<PHAsset>!
    
    //MARK:- Custom Functions    
    /**
     Create the folder in device photo library.
     */
    class func createAlbumGroup()
    {
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //print(collection.count)
        
        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.assetCollection = first_Obj as! PHAssetCollection
            //print(assetCollection)
        }
        else
        {
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                // Request creating an album with parameter name
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
                // Get a placeholder for the new album
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if(success){
                    //print("Successfully created folder")
                    let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder!.localIdentifier], options: nil)
                    
                    self.assetCollection = collection.firstObject!
                    
                    //print(assetCollection)
                }else{
                    //print("Error creating folder")
                }
            })
        }
    }
    
    /**
     To save image in device photo library.
     
     - parameter image: UIImage obj
     */
    class func saveImagesToPhotoLibrary(_ image: UIImage)
    {
        createAlbumGroup()
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset as PHFetchResult<PHAsset>)
            let enumeration: NSArray = [assetPlaceHolder!]
            if albumChangeRequest != nil {
                albumChangeRequest!.addAssets(enumeration)
                print("saveImage: image was save without issues")
            }
        }) { (success, error) in
            if success {
                //print("Save image to photo library")
            }else if error != nil{
                //print("Handle error since couldn't save image")
            }
        }
    }
    
    /**
     To save image in device photo library.
     
     - parameter image: UIImage obj
     */
    class func saveImagesToPhotoLibraryWithCompletion(_ image: UIImage, withCompletionBlock:@escaping (_ result : Bool) -> Void)
    {
        createAlbumGroup()
        
        PHPhotoLibrary.shared().performChanges({
            
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            
            self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset as PHFetchResult<PHAsset>)
            if albumChangeRequest != nil {
                albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
            }
        }) { (success, error) in
            if success {
                //print("Save image to photo library")
                withCompletionBlock(success)
            }else if error != nil{
                //print("Handle error since couldn't save image")
                withCompletionBlock(false)
            }
        }
    }
    
    /**
     To save video in device photo library.
     
     - parameter videoUrl: created video url
     */
    class func saveVideosToPhotoLibrary(_ videoUrl: URL, withCompletionBlock:@escaping (_ result : Bool) -> Void)
    {
        //createAlbumGroup()
        Singleton.sharedInstance.delay(0.5) {
            
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
                let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
                
                self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset as PHFetchResult<PHAsset>)
                albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
                
            }, completionHandler: { (success, error) in
                if success {
                    //print("Save video to photo library")
                    AlertView.showToastAt(UIScreen.main.bounds.size.height - 200, viewHeight: 45.0, viewWidth: UIScreen.main.bounds.size.width, bgColor: Macros.Colors.yellowColor, shadowColor: UIColor.gray, txtColor: UIColor.white, onScreenTime: 3, title: NSLocalizedString("Save_Recording", comment: ""), view: nil)
                    withCompletionBlock(true)
                }else if error != nil{
                    //print("Handle error since couldn't save video")
                    print("\(String(describing: error?.localizedDescription))")
                    AlertView.showToastAt(UIScreen.main.bounds.size.height - 200, viewHeight: 45.0, viewWidth: UIScreen.main.bounds.size.width, bgColor: Macros.Colors.yellowColor, shadowColor: UIColor.gray, txtColor: UIColor.white, onScreenTime: 3, title: NSLocalizedString("Couldn't_Save_Recording", comment: ""), view: nil)
                    withCompletionBlock(false)
                }
            })
        }
    }
    
    /**
     To Fetch only images from particular asset (album) in device photo library.
     */
    class func fetchImagesFromPhotoLibraryCustomAlbum()
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
        //This will fetch all the image assets in the collection
        let imageAsset = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        //print("Identifier: \(assetCollection.localizedTitle)  Images count: \(imageAsset.count)")
        
        if imageAsset.count > 0
        {
            imageItems.removeAll()
            getImagesFromAsset(imageAsset, completion: { (result) in
                if result == true {
                    //print("Img Count: \(imageItems.count)")
                    //print(imageItems)
                }
            })
        }
    }
    
    /**
     To fetch only videos from particular asset/album in device photo library.
     */
    class func fetchVideosFromPhotoLibraryCustomAlbum()
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.video.rawValue)
        let videoAsset = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        //print("Identifier: \(assetCollection.localizedTitle)  video count: \(videoAsset.count)")
        if videoAsset.count > 0
        {
            for _ in 0..<videoAsset.count {
                //fetch Asset here
                //print(videoAsset[index])
            }
        }
    }
    
    /**
     To fetch all data from device photo library.
     
     - parameter albumName: Album Name.
     */
    class func fetchAllAsset(_ albumName : String!)
    {
        if albumName == nil
        {
            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            // Fetch all albums from photo library
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            
            imageItems.removeAll()
            
            userAlbums.enumerateObjects({ (collection, start, stop) in
                //if let collection = PHCollection as? PHAssetCollection {
                
                //For each PHAssetCollection that is returned from userAlbums: PHFetchResult you can fetch PHAssets like so (you can even limit results to include only photo assets):
                
                // To fetch only video
                let onlyVideosOptions = PHFetchOptions()
                onlyVideosOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                onlyVideosOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.video.rawValue)
                let videoAsset = PHAsset.fetchAssets(in: collection, options: onlyVideosOptions)
                //print("Identifier: \(collection.localizedTitle)  video count: \(videoAsset.count)")
                if videoAsset.count > 0
                {
                    for _ in 0..<videoAsset.count {
                        //fetch Asset here
                        //print(videoAsset[index])
                    }
                }
                
                // To fetch only images
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
                let imageAsset = PHAsset.fetchAssets(in: collection, options: onlyImagesOptions)
                //print("Identifier: \(collection.localizedTitle)  Images count: \(imageAsset.count)")
                
                if imageAsset.count > 0
                {
                    getImagesFromAsset(imageAsset , completion: { (result) in
                        if result == true {
                            //print("Img Count: \(imageItems.count)")
                            //print(imageItems)
                        }
                    })
                }
                //}
            })
        }
        else {
            self.albumName = albumName
            //This will fetch all images in the asset collection
            //print("album title: \(assetCollection.localizedTitle)")
            fetchImagesFromPhotoLibraryCustomAlbum()
            
            // To fetch only video
            fetchVideosFromPhotoLibraryCustomAlbum()
        }
    }
    
    /**
     Get images from particular asset.
     
     - parameter asset: Asset name to get images.
     */
    class func getImagesFromAsset(_ assetResult: PHFetchResult<PHAsset>, completion: @escaping (_ result: Bool) -> Void)
    {
        //Enumerating objects to get a chached image - This is to save loading time
        assetResult.enumerateObjects(_:) { (object, count, stop) in
            let asset = object
            let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            let imageManager = PHCachingImageManager()
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: {(image: UIImage?,
                info: [AnyHashable: Any]?) in
                
                imageItems.append(image!)
                
                if assetResult.count-1 == count {
                    completion(true)
                }
            })
        }
    }
}
