//
//  InstagramManager.swift
//  SocialMediaSharing
//
//  Created by Tankar Shah on 29/08/19.
//  Copyright © 2019 Tankar Shah. All rights reserved.
//

import Foundation
import UIKit
import Photos

//let documentInteractionController = UIDocumentInteractionController()

class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let documentInteractionController = UIDocumentInteractionController()
    private let kInstagramURL = "instagram://app"
    private let kUTI = "com.instagram.photo"
    private let kfileNameExtension = "instagram.ig"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            
            do {
            try UIImageJPEGRepresentation(imageInstagram, 0.7)?.write(to: URL(fileURLWithPath: jpgPath), options: .atomic)
            } catch {
                print(error)
            }

            let rect = CGRect.zero
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            
            
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = kUTI
            
            // adding caption for the image
//            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
        }
        else {
            
            // alert displayed when the instagram application is not available in the device
            if let url = URL(string: INSTAGRAM_APP_STORE_URL) {
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func postImageToInstagramWithOSFlow(imageInstagram: UIImage) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            
            do {
                try UIImageJPEGRepresentation(imageInstagram, 0.7)?.write(to: URL(fileURLWithPath: jpgPath), options: .atomic)
            } catch {
                print(error)
            }
            
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            let path = fileURL.absoluteString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let instagram = URL(string: String(format : "%@camera",kInstagramURL))
            if UIApplication.shared.canOpenURL(instagram!){
                UIApplication.shared.openURL(instagram!)
            }
        }
        else {
            
            // alert displayed when the instagram application is not available in the device
            if let url = URL(string: INSTAGRAM_APP_STORE_URL) {
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func postImageToInstagramWithInstagramFlow(imageInstagram: UIImage) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
            
                UIImageWriteToSavedPhotosAlbum(imageInstagram, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                break
                
            case .denied, .restricted :
            //handle denied status
                SKToast.show(withMessage: "Photo access denied. To enable again, goto setting app and allow photo permission of app again", withType: ToastColor.Warning.rawValue)
                break
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                    // as above
                        UIImageWriteToSavedPhotosAlbum(imageInstagram, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        break
                    case .denied, .restricted:
                    // as above
                        SKToast.show(withMessage: "Photo access denied. To enable again, goto setting app and allow photo permission of app again", withType: ToastColor.Warning.rawValue)
                        break
                    case .notDetermined:
                        // won't happen but still
                        break
                    }
                }
            }
        } else{
            if let url = URL(string: INSTAGRAM_APP_STORE_URL) {
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func getCameraRoll() -> [PHAssetCollection] {
        var cameraRollAlbum = [PHAssetCollection]()
        
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        cameraRoll.enumerateObjects({ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection {
                let obj:PHAssetCollection = object as! PHAssetCollection
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let assets = PHAsset.fetchAssets(in: obj, options: fetchOptions)
                
                if assets.count > 0 {
                    cameraRollAlbum.append(obj)
                }
            }
        })
        return cameraRollAlbum
    }
    
    @objc func image(_ image: UIImage?, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if error == nil {
            // saved successfully
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let InstaAsset = PHAsset.fetchAssets(with: .image, options: fetchOptions).firstObject
            if InstaAsset != nil {
//                let cameraRollAlbum : [PHAssetCollection] = self.getCameraRoll()
//                let album : PHAssetCollection = cameraRollAlbum.first!
                InstaAsset?.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictData) in
                    if InstaAsset?.mediaType == .image{
                        if let strURL = contentEditingInput?.fullSizeImageURL?.absoluteString {
                            let path = strURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                            let instagram = URL(string: String(format : "instagram://library?AssetPath=%@",path!))
                            UIApplication.shared.openURL(instagram!)
//                            PHPhotoLibrary.shared().performChanges({
//                                PHAssetChangeRequest.deleteAssets([InstaAsset!] as NSArray)
//                            }) { (result, error) in
//                                print("completionBlock",result)
//                            }
                        }
                    }
                })
            }
        } else {
            if let error = error {
                print("save image error: \(error)")
            }
        }
    }
}


