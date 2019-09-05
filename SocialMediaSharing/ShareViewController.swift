//
//  ShareViewController.swift
//  SocialMediaSharing
//
//  Created by Tankar Shah on 29/08/19.
//  Copyright © 2019 Tankar Shah. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookShare
import TwitterKit

private let canOpenFacebookURL = "fbauth2"
private let canOpenTwitterURL = "twitterauth"

let INSTAGRAM_APP_STORE_URL = "https://apps.apple.com/in/app/instagram/id389801252"
let FACEBOOK_APP_STORE_URL = "https://apps.apple.com/in/app/facebook/id284882215"
let TWITTER_APP_STORE_URL = "https://apps.apple.com/in/app/twitter/id333903271"
let FACEBOOK_SHARE_MESSAGE = "Clipboard copy success! Press and hold in the next screen to paste."
let INSTAGRAM_SHARE_MESSAGE = "Clipboard copy success! Press and hold in the next screen to paste."

enum ToastColor : Int
{
    case None = 0
    case Informative
    case Warning
}

class ShareViewController: UIViewController, SharingDelegate {
    
    //MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitials()
    }

    //MARK:- Custom Methods
    /** FUNCTION COMMENT
     Use : Use to setup initial configurations
     From where it is called : called from viewDidLoad
     Arguments : nil
     Return Type : nil
     **/
    func setupInitials(){
        self.title = "Social Media Sharing"
    }
    
    /** FUNCTION COMMENT
     Use : to check user has installed facebook application or not
     From where it is called : called from btnImportFromOther
     Arguments : nil
     Return Type : Bool
     **/
    func isFacebookAppInstalled() -> Bool {
        var components = URLComponents()
        components.scheme = canOpenFacebookURL
        components.path = "/"
        if let URL = components.url {
            return UIApplication.shared.canOpenURL(URL)
        }
        return false
    }
    
    /** FUNCTION COMMENT
     Use : to open sharing dialog for Facebook application
     From where it is called : called from btnImportFromOther
     Arguments : content with type of ShareMediaContent
     Return Type : nil
     **/
    @objc func openSharingDialog(content : ShareMediaContent){
        let dialog = ShareDialog()
        dialog.delegate = self
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = .automatic
        dialog.show()
    }
    
    /** FUNCTION COMMENT
     Use : to open sharing dialog for Instagram application
     From where it is called : called from btnImportFromOther
     Arguments : nil
     Return Type : nil
     **/
    @objc func openSharingDialogForInstagram(){
        InstagramManager.sharedManager.postImageToInstagramWithInstagramFlow(imageInstagram: UIImage.init(named: "logo")!)
    }
    
    /** FUNCTION COMMENT
     Use : to check user has installed twitter application or not
     From where it is called : called from btnImportFromOther
     Arguments : nil
     Return Type : Bool
     **/
    func isTwitterAppInstalled() -> Bool {
        var components = URLComponents()
        components.scheme = canOpenTwitterURL
        components.path = "/"
        if let URL = components.url {
            return UIApplication.shared.canOpenURL(URL)
        }
        return false
    }
    
    //MARK:- Facebook sharing Delegate Method
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        UIPasteboard.general.string = ""
        SKToast.show(withMessage: "Shared successfully", withType: ToastColor.Informative.rawValue)
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        UIPasteboard.general.string = ""
    }
    
    //MARK:- UIAction Methods
    @IBAction func btnFacebookAction(_ sender: Any) {
            if self.isFacebookAppInstalled(){
                let content = ShareMediaContent()
                
                var msgToShare = "This is facebook sharing"
                
                let photo = SharePhoto()
                photo.image = UIImage.init(named: "logo")
                photo.isUserGenerated = true
                
                content.media = [photo]
                
                let hsTags = "#promact #socialmediasharing #tutorial #firstapp"
                msgToShare = String(format : "%@ %@", msgToShare,hsTags)
                
                if msgToShare.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0{
                    UIPasteboard.general.string = msgToShare
                    SKToast.toastDelayTime(Time: 5)
                    SKToast.show(withMessage: FACEBOOK_SHARE_MESSAGE, withType: ToastColor.Informative.rawValue)
                }
                
                self.perform(#selector(self.openSharingDialog(content :)), with: content, afterDelay: 4.0)
            } else {
                if let url = URL(string: FACEBOOK_APP_STORE_URL) {
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.openURL(url)
                    }
                }
            }
    }
    
    @IBAction func btnTwitterAction(_ sender: Any) {
            
            if self.isTwitterAppInstalled(){
                let twPost = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
            
                var msgToShare = "This is twitter sharing"
                let hsTags = "#promact #socialmediasharing #tutorial #firstapp"
                
                if msgToShare.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0{
                    msgToShare = String(format : "%@ %@", msgToShare, hsTags)
                    twPost?.setInitialText(msgToShare)
                }
                
                twPost?.add(UIImage.init(named: "logo"))
                
                present(twPost!, animated: true)
                twPost!.completionHandler = { result in
                    switch result {
                    case .cancelled:
                        print("Post cancelled")
                    case .done:
                        print("Post Successful")
                        SKToast.show(withMessage: "Tweet successful", withType: ToastColor.Informative.rawValue)
                    default:
                        break
                    }
                    self.dismiss(animated: true)
                }
            } else {
                if let url = URL(string: TWITTER_APP_STORE_URL) {
                    if UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.openURL(url)
                    }
                }
            }
    }
    
    @IBAction func btnInstagramAction(_ sender: Any) {
        let instagramURL = NSURL(string: "instagram://app")
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            var msgToShare = "This is twitter sharing"
            let hsTags = "#promact #socialmediasharing #tutorial #firstapp"
            
            if msgToShare.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0{
                msgToShare = String(format : "%@ %@", msgToShare, hsTags)
                UIPasteboard.general.string = msgToShare
                SKToast.toastDelayTime(Time: 5)
                SKToast.show(withMessage: INSTAGRAM_SHARE_MESSAGE, withType: ToastColor.Informative.rawValue)
            }
            
            self.perform(#selector(self.openSharingDialogForInstagram), with: nil, afterDelay: 5.0)
        } else {
            if let url = URL(string: INSTAGRAM_APP_STORE_URL) {
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

