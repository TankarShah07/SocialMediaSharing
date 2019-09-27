//
//  ShareViewController.swift
//  SocialMediaSharing
//
//  Created by Tankar Shah on 29/08/19.
//  Copyright © 2019 Tankar Shah. All rights reserved.
//

import UIKit
import Contacts
import FacebookLogin
import FacebookShare
import FacebookCore
import FBSDKLoginKit
import TwitterKit
import SDWebImage


//facebook id : 382908272641375 currently used Teetra's Id

private let canOpenFacebookURL = "fbauth2"
private let canOpenTwitterURL = "twitterauth"

let INSTAGRAM_APP_STORE_URL = "https://apps.apple.com/in/app/instagram/id3898012521"
let FACEBOOK_APP_STORE_URL = "https://apps.apple.com/in/app/facebook/id2848822151"
let TWITTER_APP_STORE_URL = "https://apps.apple.com/in/app/twitter/id3339032711"
let FACEBOOK_SHARE_MESSAGE = "Clipboard copy success! Press and hold in the next screen to paste."
let INSTAGRAM_SHARE_MESSAGE = "Clipboard copy success! Press and hold in the next screen to paste."
let TWITTER_CRED_URL = "https://api.twitter.com/1.1/account/verify_credentials.json"

struct INSTAGRAM_IDS {
    
    static let INSTAGRAM_USER_INFO = "https://api.instagram.com/v1/users/self/?access_token="
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
    static let INSTAGRAM_CLIENT_ID  = "ee7a1e401ef046ca8cb274a35c03b0ce"
    static let INSTAGRAM_CLIENTSERCRET = " 5fe8cbc6ac3147dc86de0ff6a3f6308b"
    static let INSTAGRAM_REDIRECT_URI = "https://teetra.com"
    static let INSTAGRAM_ACCESS_TOKEN =  "access_token"
    static let INSTAGRAM_SCOPE = "basic"//follower_list+public_content
    static var INSTAGRAM_FETCHED_ACCESS_TOKEN =  ""
}

enum ToastColor : Int
{
    case None = 0
    case Informative
    case Warning
}

class ShareViewController: UIViewController, SharingDelegate,UIWebViewDelegate {
    
    var SharingMethod = 0
    var loginManager = LoginManager()
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewInstagram: UIView!
    
    @IBOutlet weak var facebookLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var facebookBottomConst: NSLayoutConstraint!
    @IBOutlet weak var btnDeleteFacebook: UIButton!
    @IBOutlet weak var imgFacebookUser: UIImageView!
    @IBOutlet weak var lblFacebookUserName: UILabel!
    
    @IBOutlet weak var twitterLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var twitterBottomConst: NSLayoutConstraint!
    @IBOutlet weak var btnDeleteTwitter: UIButton!
    @IBOutlet weak var imgTwitterUser: UIImageView!
    @IBOutlet weak var lblTwitterUserName: UILabel!
    
    @IBOutlet weak var instagramLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var instagramBottomConst: NSLayoutConstraint!
    @IBOutlet weak var btnDeleteInstagram: UIButton!
    @IBOutlet weak var imgInstgramUser: UIImageView!
    @IBOutlet weak var lblInstagramUserName: UILabel!
    
    
    
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
        
        //For Facebook
        if AccessToken.current != nil{
            self.facebookLeadingConst.constant = 5
            self.btnDeleteFacebook.isHidden = false
            self.imgFacebookUser.isHidden = false
            self.lblFacebookUserName.isHidden = false
            self.facebookBottomConst.constant = 80
            if self.segmentControl.selectedSegmentIndex == 0{
                if self.getLocalStorage(fileName: "facebookUserData") != nil {
                    self.setupFacebookUserData()
                }
            }
        } else {
            self.facebookLeadingConst.constant = 35
            self.btnDeleteFacebook.isHidden = true
            self.imgFacebookUser.isHidden = true
            self.lblFacebookUserName.isHidden = true
            self.facebookBottomConst.constant = 20
        }
        
        //For Twitter
        if TWTRTwitter.sharedInstance().sessionStore.session() != nil{
            self.twitterLeadingConst.constant = 5
            self.btnDeleteTwitter.isHidden = false
            self.imgTwitterUser.isHidden = false
            self.lblTwitterUserName.isHidden = false
            self.twitterBottomConst.constant = 80
            if self.segmentControl.selectedSegmentIndex == 0{
                if self.getLocalStorage(fileName: "twitterUserData") != nil {
                    self.setupTwitterUserData()
                }
            }
        } else {
            self.twitterLeadingConst.constant = 35
            self.btnDeleteTwitter.isHidden = true
            self.imgTwitterUser.isHidden = true
            self.lblTwitterUserName.isHidden = true
            self.twitterBottomConst.constant = 20
        }
        
        //For Instagram
        let instaAuth = UserDefaults.standard.object(forKey: "InstagramAuth")
        if instaAuth != nil{
            self.instagramLeadingConst.constant = 5
            self.btnDeleteInstagram.isHidden = false
            self.imgInstgramUser.isHidden = false
            self.lblInstagramUserName.isHidden = false
            self.instagramBottomConst.constant = 80
            if self.segmentControl.selectedSegmentIndex == 0{
                if self.getLocalStorage(fileName: "instagramUserData") != nil {
                    self.setupInstagramUserData()
                }
            }
        } else {
            self.instagramLeadingConst.constant = 35
            self.btnDeleteInstagram.isHidden = true
            self.imgInstgramUser.isHidden = true
            self.lblInstagramUserName.isHidden = true
            self.instagramBottomConst.constant = 20
        }
    }
    
    /** FUNCTION COMMENT
     Use : to check user has installed facebook application or not
     From where it is called : called from btnFacebookAction
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
     From where it is called : called from facebookShareOldWay
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
     Use : to get stored facebook user's data
     From where it is called : called from facebookShareNewWay
     Arguments : nil
     Return Type : nil
     **/
    func getFacebookUserData(){
        
        let graphPath = "me"
        let parameters = ["fields":"email, first_name, last_name, gender, picture,id"]
        
        let request = GraphRequest(graphPath: graphPath, parameters: parameters, tokenString: AccessToken.current?.tokenString, version: nil , httpMethod: .get)
        
        request.start { (connection, result, error) in
            
            if let error = error{
                print(error)
            }
            else{
                if let result = result as? [String: Any] {
                    let dictUserInfo : NSMutableDictionary = NSMutableDictionary(dictionary: result as NSDictionary)
                    
                    if dictUserInfo.count > 0{
                        self.setLocalStorage(dictUserInfo as? [AnyHashable : Any], fileName: "facebookUserData")
                        self.setupFacebookUserData()
                        UIView.animate(withDuration: 0.2) {
                            self.setupInitials()
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    /** FUNCTION COMMENT
     Use : to setup stored facebook user's data into label and imageview
     From where it is called : called from setupInitials,getFacebookUserData
     Arguments : nil
     Return Type : nil
     **/
    func setupFacebookUserData(){
        
        let dictUserInfo = self.getLocalStorage(fileName: "facebookUserData")
        var name :String = ""
        if dictUserInfo!["first_name"] != nil{
            name = dictUserInfo!["first_name"] as! String
            if dictUserInfo!["last_name"] != nil{
                name = String(format : "%@ %@", name, dictUserInfo!["last_name"] as! String)
            }
            self.lblFacebookUserName.text = name
        }
        
        if let dictProfilePic = dictUserInfo!["picture"] as? [String : Any]{
            if let profileData = dictProfilePic["data"] as? [String : Any]
            {
                if let profileURL = profileData["url"] as? String
                {
                    self.imgFacebookUser!.sd_setImage(with: (URL(string: profileURL))!, placeholderImage: nil , completed: { (image, error, disk, imageURL) in
                        if error == nil {
                        }
                    })
                    
                } else {
                    //self.imgFacebookUser.image = UIImage(data: imgData!)
                    //placeholder image
                }
            } else {
                //self.imgFacebookUser.image = UIImage(data: imgData!)
                //placeholder image
            }
        }
    }
    
    /** FUNCTION COMMENT
     Use : to share post on facebook with new concept of by fetching userobject
     From where it is called : called from btnFacebookAction
     Arguments : nil
     Return Type : nil
     **/
    func facebookShareNewWay(){
        if AccessToken.current != nil{
            self.facebookShareOldWay()
        } else {
            self.loginManager.logIn(permissions: [.email,.publicProfile, .userFriends], viewController: self) { (loginResult) in
                
                switch loginResult {
                case .failed(let error):
                    //                self.hideSpinner()
                    print(error)
                    
                case .cancelled:
                    //                self.hideSpinner()
                    print("User cancelled login.")
                    
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in! Granted Permissions : \(grantedPermissions) & Declined Permissions : \(declinedPermissions) & Access Token :\(accessToken)")
                    self.getFacebookUserData()
                    
                }
            }
        }
    }
    
    /** FUNCTION COMMENT
     Use : to share post on facebook with already developed in version1.0
     From where it is called : called from btnFacebookAction,facebookShareNewWay
     Arguments : nil
     Return Type : nil
     **/
    func facebookShareOldWay(){
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
    }
    
    /** FUNCTION COMMENT
     Use : to open sharing dialog for Instagram application
     From where it is called : called from instagramShareOldWay
     Arguments : nil
     Return Type : nil
     **/
    @objc func openSharingDialogForInstagram(){
        InstagramManager.sharedManager.postImageToInstagramWithInstagramFlow(imageInstagram: UIImage.init(named: "logo")!)
    }
    
    /** FUNCTION COMMENT
     Use : to check user has installed twitter application or not
     From where it is called : called from btnTwitterAction
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
    
    /** FUNCTION COMMENT
     Use : to setup instagram user's data into label, imageview
     From where it is called : called from getUserInfo,setupInitials
     Arguments : nil
     Return Type : nil
     **/
    func setupInstagramUserData(){
        
        let dictUserInfo = self.getLocalStorage(fileName: "instagramUserData")
        if dictUserInfo!["data"] != nil{
            let dictData = dictUserInfo!["data"] as! [String : Any]
            
            DispatchQueue.main.async {
                self.lblInstagramUserName.text = String(format : "%@", dictData["full_name"] as! String)
            }
            
            if dictData["profile_picture"] != nil {
                self.imgInstgramUser!.sd_setImage(with: (URL(string: dictData["profile_picture"] as! String))!, placeholderImage: nil , completed: { (image, error, disk, imageURL) in
                    if error == nil {
                    }
                })
            } else {
                //self.imgFacebookUser.image = UIImage(data: imgData!)
                //placeholder image
            }
        }
    }
    
    /** FUNCTION COMMENT
     Use : to setup instagram user's data into label, imageview
     From where it is called : called from checkRequestForCallbackURL
     Arguments : nil
     Return Type : completion block
     **/
    func getUserInfo(completion: @escaping ((_ data: Bool) -> Void)){
        let url = String(format: "%@%@", arguments: [INSTAGRAM_IDS.INSTAGRAM_USER_INFO,INSTAGRAM_IDS.INSTAGRAM_FETCHED_ACCESS_TOKEN])
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard error == nil else {
                completion(false)
                //failure
                return
            }
            // make sure we got data
            guard let responseData = data else {
                completion(false)
                //Error: did not receive data
                return
            }
            do {
                guard let dataResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: AnyObject] else {
                        completion(false)
                        //Error: did not receive data
                        return
                }
                self.setLocalStorage(dataResponse as? [AnyHashable : Any], fileName: "instagramUserData")
                self.setupInstagramUserData()
                completion(true)
                // success (dataResponse) dataResponse: contains the Instagram data
            } catch let err {
                completion(false)
                //failure
            }
        })
        task.resume()
    }
    
    func instagramShareNewWay(){
        let instaAuth = UserDefaults.standard.object(forKey: "InstagramAuth")
        if instaAuth != nil{
            self.instagramShareOldWay()
        } else {
            self.viewInstagram.isHidden = false
            loginWebView.delegate = self
            unSignedRequest()
        }
    }
    
    func instagramShareOldWay(){
        var msgToShare = "This is twitter sharing"
        let hsTags = "#promact #socialmediasharing #tutorial #firstapp"
        
        if msgToShare.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0{
            msgToShare = String(format : "%@ %@", msgToShare, hsTags)
            UIPasteboard.general.string = msgToShare
            SKToast.toastDelayTime(Time: 5)
            SKToast.show(withMessage: INSTAGRAM_SHARE_MESSAGE, withType: ToastColor.Informative.rawValue)
        }
        
        self.perform(#selector(self.openSharingDialogForInstagram), with: nil, afterDelay: 5.0)
    }
    
    func setupTwitterUserData(){
        
        let dictUserInfo = self.getLocalStorage(fileName: "twitterUserData")
        if dictUserInfo!["name"] != nil{
            self.lblTwitterUserName.text = dictUserInfo!["name"] as? String
        }
        
        if let profileURL = dictUserInfo!["profile_image_url"] as? String {
            self.imgTwitterUser!.sd_setImage(with: (URL(string: profileURL))!, placeholderImage: nil , completed: { (image, error, disk, imageURL) in
                if error == nil {
                }
            })
        } else {
            //self.imgTwitterUser.image = UIImage(data: imgData!)
            //placeholder image
        }
    }
    
    func twitterShareNewWay(){
        
        if (TWTRTwitter.sharedInstance().sessionStore.session() != nil){
            self.twitterShareOldWay()
        } else {
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if (session != nil) {
                    print("User Name \(String(describing: session?.userName))");
                    print("User Id \(String(describing: session?.userID))");
                    print("AuthToken \(String(describing: session?.authToken))");
                    
                    let client = TWTRAPIClient.withCurrentUser()
                    let request = client.urlRequest(withMethod: "GET",
                                                    urlString: TWITTER_CRED_URL,
                                                    parameters: ["include_email": "true", "skip_status": "true"],
                                                    error: nil)
                    client.sendTwitterRequest(request)
                    { response, data, connectionError in
                        if connectionError != nil {
                            print(connectionError.debugDescription)
                        } else {
                            print(response as Any)
                            
                            do {
                                let jsonUserInfo = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                                
                                let dictUserIfo = NSMutableDictionary(dictionary: jsonUserInfo! as NSDictionary)
                                self.setLocalStorage(dictUserIfo as? [AnyHashable : Any], fileName: "twitterUserData")
                                self.setupTwitterUserData()
                                UIView.animate(withDuration: 0.2) {
                                    self.setupInitials()
                                    self.view.layoutIfNeeded()
                                }
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                } else {
                    //error
                }
            })
        }
    }
    
    func twitterShareOldWay(){
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
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        loginWebView.loadRequest(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            self.webViewDidFinishLoad(self.loginWebView)
            self.viewInstagram.isHidden = true
            self.getUserInfo(){(data) in
                print(data)
            }
            UIView.animate(withDuration: 0.2) {
                self.setupInitials()
                self.view.layoutIfNeeded()
            }
            return false
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        INSTAGRAM_IDS.INSTAGRAM_FETCHED_ACCESS_TOKEN = authToken
        print("Instagram authentication token ==", authToken)
        UserDefaults.standard.set(authToken, forKey: "InstagramAuth")
        UserDefaults.standard.synchronize()
    }
    
    
    // MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = false
        loginIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = true
        loginIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewDidFinishLoad(webView)
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
            if SharingMethod == 0 {
                self.facebookShareNewWay()
            } else {
                self.facebookShareOldWay()
            }
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
            if SharingMethod == 0 {
                self.twitterShareNewWay()
            } else {
                self.twitterShareOldWay()
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
            if SharingMethod == 0 {
                self.instagramShareNewWay()
            } else {
                self.instagramShareOldWay()
            }
        } else {
            if let url = URL(string: INSTAGRAM_APP_STORE_URL) {
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @IBAction func btnDeleteFacebookClick(_ sender: Any) {
        if AccessToken.current != nil{
            self.removeLocalStorage(fileName: "facebookUserData")
            self.facebookLeadingConst.constant = 35
            self.facebookBottomConst.constant = 20
            UIView.animate(withDuration: 0.2) {
                self.btnDeleteFacebook.isHidden = true
                self.imgFacebookUser.isHidden = true
                self.lblFacebookUserName.isHidden = true
                self.view.layoutIfNeeded()
            }
            self.loginManager.logOut()
            SKToast.show(withMessage: "Facebook account removed successfully", withType: ToastColor.Informative.rawValue)
        }
    }
    
    @IBAction func btnDeleteTwitterClick(_ sender: Any) {
        if (TWTRTwitter.sharedInstance().sessionStore.session()?.userID) != nil{
            self.twitterLeadingConst.constant = 35
            self.twitterBottomConst.constant = 20
            self.removeLocalStorage(fileName: "twitterUserData")
            UIView.animate(withDuration: 0.2) {
                self.btnDeleteTwitter.isHidden = true
                self.imgTwitterUser.isHidden = true
                self.lblTwitterUserName.isHidden = true
                self.view.layoutIfNeeded()
            }
            SKToast.show(withMessage: "Twitter account removed successfully", withType: ToastColor.Informative.rawValue)
            TWTRTwitter.sharedInstance().sessionStore.logOutUserID((TWTRTwitter.sharedInstance().sessionStore.session()?.userID)!)
        }
    }

    @IBAction func btnDeleteInstagramClick(_ sender: Any) {
        let instaAuth = UserDefaults.standard.object(forKey: "InstagramAuth")
        if instaAuth != nil{
            let cookies : HTTPCookieStorage = HTTPCookieStorage.shared
            let instaCookies : [HTTPCookie] = cookies.cookies!
            for myCookie in instaCookies {
                if myCookie.domain == ".instagram.com" {
                    cookies.deleteCookie(myCookie)
                }
            }
            
            self.instagramLeadingConst.constant = 35
            self.instagramBottomConst.constant = 20
            self.removeLocalStorage(fileName: "instagramUserData")
            UIView.animate(withDuration: 0.2) {
                self.btnDeleteInstagram.isHidden = true
                self.imgInstgramUser.isHidden = true
                self.lblInstagramUserName.isHidden = true
                self.view.layoutIfNeeded()
            }
            UserDefaults.standard.removeObject(forKey: "InstagramAuth")
            UserDefaults.standard.synchronize()
            SKToast.show(withMessage: "Instagram account removed successfully", withType: ToastColor.Informative.rawValue)
        }
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        self.viewInstagram.isHidden = true
    }
    
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        if self.segmentControl.selectedSegmentIndex == 0 {
            self.segmentControl.selectedSegmentIndex = 0
            self.SharingMethod = 0
            UIView.animate(withDuration: 0.2) {
                self.setupInitials()
                self.view.layoutIfNeeded()
            }
        } else {
            self.segmentControl.selectedSegmentIndex = 1
            self.SharingMethod = 1
            self.facebookLeadingConst.constant = 35
            self.twitterLeadingConst.constant = 35
            self.instagramLeadingConst.constant = 35
            
            self.facebookBottomConst.constant = 20
            self.twitterBottomConst.constant = 20
            self.instagramBottomConst.constant = 20
            
            UIView.animate(withDuration: 0.2) {
                self.btnDeleteFacebook.isHidden = true
                self.imgFacebookUser.isHidden = true
                self.lblFacebookUserName.isHidden = true
                
                self.btnDeleteTwitter.isHidden = true
                self.imgTwitterUser.isHidden = true
                self.lblTwitterUserName.isHidden = true
                
                self.btnDeleteInstagram.isHidden = true
                self.imgInstgramUser.isHidden = true
                self.lblInstagramUserName.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - SLocal Storage
    
    /** FUNCTION COMMENT
     Use : to set work Matrics data into file and save it to prefrences of app
     From where it is called : called from Marketplace class
     Arguments : dictData of types [AnyHashable : Any]
     Return Type : nil
     **/
    func setLocalStorage(_ dictData: [AnyHashable : Any]?, fileName : String) {
        var data: NSData? = nil
        if let dictData = dictData {
            data = NSKeyedArchiver.archivedData(withRootObject: dictData) as NSData
        }
        var pathForSavedFile = fileName
        pathForSavedFile = pathForSavedFile.pathInDocumentDirectory()
        if FileManager.default.fileExists(atPath: pathForSavedFile) {
            try? FileManager.default.removeItem(atPath: pathForSavedFile)
        }
        data?.write(toFile: pathForSavedFile, atomically: false)
    }
    
    /** FUNCTION COMMENT
     Use : to get work Matrics data from file which is stored in prefrences of app
     From where it is called : called from Marketplace class
     Arguments : dictData of types [AnyHashable : Any]
     Return Type : nil
     **/
    func getLocalStorage(fileName : String) -> [AnyHashable : Any]? {
        var pathForSavedFile = fileName
        pathForSavedFile = pathForSavedFile.pathInDocumentDirectory()
        let dataget = NSData(contentsOfFile: pathForSavedFile) as Data?
        var dictData: [AnyHashable : Any]? = nil
        if let dataget = dataget {
            dictData = NSKeyedUnarchiver.unarchiveObject(with: dataget) as? [AnyHashable : Any]
        }
        return dictData
    }
    
    /** FUNCTION COMMENT
     Use : to remove stored work Matrics file which is stored in prefrences of app
     From where it is called : called from Marketplace class
     Arguments : nil
     Return Type : nil
     **/
    func removeLocalStorage(fileName : String) {
        let fileManager = FileManager.default
        var pathForSavedFile = fileName
        pathForSavedFile = pathForSavedFile.pathInDocumentDirectory()
        let success = try? fileManager.removeItem(atPath: pathForSavedFile)
        if (success != nil) {
        } else {
        }
    }
}

