//
//  ViewController.swift
//  SocialMediaSharing
//
//  Created by Rajtharan Gopal on 08/11/17.
//  Copyright © 2017 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

public enum ShareType {
    case link
    case multimedia
}

class ViewController: UIViewController {
    
    var imagePickerController: UIImagePickerController?

    // MARK:- View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:- Custom methods
    
    func getFacebookLinkContent() -> FBSDKShareLinkContent {
        let linkContent = FBSDKShareLinkContent()
        if let url = URL(string: "https://developers.facebook.com") {
            linkContent.contentURL = url
            linkContent.quote = "Quote this message MadeWithHackbook" // Add a quote object if needed.
        }
        return linkContent
    }
    
    func facebookLinkShareDialog() {
        let linkContent = getFacebookLinkContent()
        let fbShareDialog = FBSDKShareDialog()
        fbShareDialog.fromViewController = self
        fbShareDialog.shareContent = linkContent
        fbShareDialog.mode = .automatic
        fbShareDialog.shouldFailOnDataError = true
        fbShareDialog.show()
    }
    
    func uploadImageToFacebook(image: UIImage) {
        let sharePhoto = FBSDKSharePhoto(image: image, userGenerated: true)
        let photoContent = FBSDKSharePhotoContent()
        photoContent.photos = [sharePhoto!]
        photoContent.hashtag = FBSDKHashtag(string: "#SharingPhotos") // Add a hastag object if needed.
        FBSDKShareDialog.show(from: self, with: photoContent, delegate: self)
    }
    
    func uploadVideoToFacebook(videoUrl: URL) {
        let shareVideo = FBSDKShareVideo(videoURL: videoUrl)
        let videoContent = FBSDKShareVideoContent()
        videoContent.video = shareVideo
        videoContent.hashtag = FBSDKHashtag(string: "#SharingVideos") // Add a hastag object if needed.
        FBSDKShareDialog.show(from: self, with: videoContent, delegate: self)
    }
    
    func facebookLinkShareMessenger() {
        let linkContent = getFacebookLinkContent()
        let fbMessangerDialog = FBSDKMessageDialog()
        fbMessangerDialog.shareContent = linkContent
        fbMessangerDialog.shouldFailOnDataError = true
        if fbMessangerDialog.canShow() {
            FBSDKMessageDialog.show(with: linkContent, delegate: self)
        } else {
            // Messenger share not supported in iPads
        }
    }
    
    func showPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        let authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .denied:
            showAlert(title: "Oops!", withMessage: "Please enable the app to access the Photo Library.")
            break
        case .restricted:
            showAlert(title: "Oops!", withMessage: "Please enable the app to access the Photo Library.")
            break
        case .authorized:
            self.present(picker, animated: true, completion: nil)
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .denied || authorizationStatus == .notDetermined || authorizationStatus == .restricted {
                    return
                } else {
                    self.present(picker, animated: true, completion: nil)
                }
            })
            break
        }
    }
    
    func showAlert(title: String?, withMessage message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Okay button
        let okay = UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
            if let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okay)
        alert.addAction(cancel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareLinkSegue" {
            let shareVC = segue.destination as! ShareViewController
            shareVC.shareType = ShareType.link
            shareVC.delegate = self
        } else if segue.identifier == "shareMultimediaSegue" {
            let shareVC = segue.destination as! ShareViewController
            shareVC.shareType = ShareType.multimedia
            shareVC.delegate = self
        }
    }
    
}

// MARK:- ShareViewController delegate methods

extension ViewController: ShareViewControllerDelegate {
    
    func facebookSharePressed(type: ShareType) {
        if type == .link {
            facebookLinkShareDialog()
        } else if type == .multimedia {
            showPhotoLibrary()
        }
    }
    
}

// MARK:- UIImagePickerController Delegate Methods

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType.isEqual(kUTTypeImage as String) { // Media is an image
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            dismiss(animated: true) {
                self.uploadImageToFacebook(image: image)
            }
        } else if mediaType.isEqual(kUTTypeMovie as String) { // Media is a video
            let videoUrl = info[UIImagePickerControllerReferenceURL] as! URL
            dismiss(animated: true, completion: {
                self.uploadVideoToFacebook(videoUrl: videoUrl)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK:- FBSDKSharingDelegate Methods

extension ViewController: FBSDKSharingDelegate {
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("Sharing has been completed.")
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("Sharing has failed with error \(error)")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        // User has cancelled the share dialog
    }
    
}


