//
//  HEDocDirectory.swift
//  HeroEyez-ClassRoom
//
//  Created by MANISH_iOS on 14/11/16.
//  Copyright © 2016 Delaplex Softwares. All rights reserved.
//

import UIKit

/// HEDocDirectory class is used to store data in document deirectory.
class HEDocDirectory: NSObject
{
    //MARK:- Variables
    /// Singltone object of HEDocDirectory
    static let shared = HEDocDirectory()
    /// Default file manager object
    let fileManagerDefault  = FileManager.default
    /// Document directory path
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    /// Document directory domain mask
    let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
    /// Documents path where to store data
    let documentsPath       = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    /// Custom directory path
    var customDirectoryPath : URL!
    /// Completion block
    typealias FileSaveCompletionBlock = (_ status : Bool?, _ path : URL?) -> Void
    
    //MARK:- Default methods
    /// Init method
    override init()
    {
        super.init()
    }
    
    //MARK:- Custom functions
    /**
     To create a folder in a the document directory of file system assigned for our app.
     
     - parameter nameDir: Name of the directory you want to create
     
     - returns: String with a success failure message.
     */
    func createDirectoryWithName(_ nameDir : String, savePath : Bool) -> String!
    {
        let directoryPath = documentsPath.appendingPathComponent(nameDir)
        
        savePath == true ? (customDirectoryPath = directoryPath) : (customDirectoryPath = URL(fileURLWithPath: ""))
        
        if checkIfDirectoryExistAtPath(directoryPath) == false
        {
            do
            {
                try fileManagerDefault.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
                return "created"
            }catch let error as NSError
            {
                let err = "Unable to create directory \(error.debugDescription)"
                //NSLog(err)
                return err
            }
        }else
        {
            return "Directory is already available"
        }
    }
    
    /**
     Clear temporary folder in directory.
     */
    func clearTmpDirectory()
    {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            //print(error)
        }
    }
    
    /**
     To get the urls of all files regardless of its type from a particalur folder in a document directory
     
     - parameter nameDir: Name of the directory
     
     - returns: [NSURL] - Array of URL path of all the files in a folder of a document directory.
     */
    func getAllTypeFilesInDirectory(_ nameDir : String!) -> [URL]
    {
        let directoryPath = documentsPath.appendingPathComponent(nameDir)
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: directoryPath, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            return directoryContents
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
        return []
    }
    
    /**
     Get asset data using URL from Directory.
     */
    func getImageDataAtURL(_ path : String) -> Data
    {
        if fileManagerDefault.fileExists(atPath: path)
        {
            return (try! Data(contentsOf: URL(fileURLWithPath:path)))
        }else{
            //print("No Image")
            return Data()
        }
    }
    
    /**
     Get Image using URL from Directory.
     */
    func getImageAtPath(_ path : String) -> UIImage?
    {
        //print("image path is \(path)")
        if FileManager.default.fileExists(atPath: path)
        {
            return UIImage(contentsOfFile: path)
        }else{
            //print("No Image")
            return nil
        }
    }
    
    /**
     Get all the file path as [NSURL] in a particular document directory folder
     
     - parameter nameDir: Name of the directory
     
     - returns: [NSURL] -> array of NSURL of all the image files in a directory
     */
    func getImagesInDirectory(_ nameDir : String) -> [URL]!
    {
        let directoryPath = documentsPath.appendingPathComponent(nameDir)
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: directoryPath, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let pngFiles = directoryContents.filter{ $0.pathExtension == "jpeg" }
            // //print("png urls:",pngFiles)
            // //print("png list:", getAllFileNameFromURL(pngFiles))
            return pngFiles
            
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
        return []
    }
    
    /**
     To exclude the path and extension and get only file name for a array of particular url
     
     - parameter arr: [NSURL] - Array of URL in a folder in doucment directory
     
     - returns: [String] - Array of all file name.
     */
    func getAllFileNameFromURL(_ arr : [URL]) -> [String]
    {
        return  arr.flatMap({$0.deletingPathExtension().lastPathComponent})
    }
    
    //MARK:- Delete
    /**
     Remove particular asset from document directory.
     */
    func removeFileInDirectory(_ filePath : URL)
    {
        do
        {
            try fileManagerDefault.removeItem(at: filePath)
        }catch _ as NSError
        {
            //print("Unable to delete file at - \(filePath) \n Error is \(error)")
        }
    }
    
    /**
     Remove all files from doucment directory folder path
     
     - parameter directoryPath: path of the folder in document directory
     */
    func removeAllFilesInDirectory()
    {
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try fileManagerDefault.contentsOfDirectory( at: documentsPath, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            for path in directoryContents
            {
                removeFileInDirectory(path)
            }
        } catch _ as NSError {
            //print(error.localizedDescription) let error
        }
    }
    
    /**
     Remove all assets from specific directory.
     */
    func removeAllFilesInSpecificDirectory(dName: String)
    {
        let directoryPath = documentsPath.appendingPathComponent(dName, isDirectory: true)
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try fileManagerDefault.contentsOfDirectory( at: directoryPath, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            for path in directoryContents
            {
                removeFileInDirectory(path)
            }
        } catch _ as NSError
        {
            //print(error.localizedDescription) let error
        }
    }
    
    //MARK:- Save files to document directory
    /**
     Save image at document directory path.
     */
    func saveImageToPath(_ imgData : Data, name : String, withCompletion: FileSaveCompletionBlock)
    {
        if Double(DiskStatus.freeDiskSpaceInBytes) / 1000000000 < 0.5
        {
            withCompletion(false, nil)
        }
        
        if customDirectoryPath == nil
        {
            let _ = createDirectoryWithName(Macros.Constants.evidenceFolderName, savePath: true)
        }
        
        var newPath : URL = customDirectoryPath.appendingPathComponent(name).appendingPathExtension("jpeg")
        
        if checkIfFileExistAtPath(newPath) == true
        {
            newPath     = newPath.deletingPathExtension()
            newPath     = newPath.appendingPathComponent("-copyAt\(Date().timeIntervalSince1970)").appendingPathExtension("jpeg") //JPEG
        }
        
        do
        {
            try imgData.write(to: newPath, options: .withoutOverwriting)
            Macros.Constants.imagePathForServer.append(newPath.path)
            withCompletion(true, newPath)
            
        }catch let error as NSError
        {
            print(error.localizedDescription)
            withCompletion(false, nil)
        }
    }
    
    /**
     Chack file is exist or not at document directory path.
     */
    func checkIfFileExistAtPath(_ filePath : URL) -> Bool
    {
        var isDir: ObjCBool = false
        var isDirAvailable = false
        
        if fileManagerDefault.fileExists(atPath: filePath.absoluteString, isDirectory: &isDir)
        {
            isDir.boolValue ? (isDirAvailable = true) : (isDirAvailable = false)
        }else
        {
            isDirAvailable = false
        }
        
        return isDirAvailable
    }
    
    /**
     Check folder name exist or not at document directory.
     */
    func checkIfDirectoryExistAtPath(_ directoryPath : URL, isDirPass: ObjCBool = false) -> Bool
    {
        var isDir: ObjCBool = isDirPass
        var isDirAvailable = false
        
        if fileManagerDefault.fileExists(atPath: directoryPath.absoluteString, isDirectory: &isDir)
        {
            isDir.boolValue ? (isDirAvailable = true) : (isDirAvailable = false)
        }else
        {
            isDirAvailable = false
        }
        
        return isDirAvailable
    }
}

