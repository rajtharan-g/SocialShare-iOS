//
//  ShareViewController.swift
//  SocialMediaSharing
//
//  Created by Rajtharan Gopal on 10/11/17.
//  Copyright © 2017 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit

protocol ShareViewControllerDelegate {
    func facebookSharePressed(type: ShareType)
}

class ShareViewController: UIViewController {
    
    var delegate: ShareViewControllerDelegate?
    var shareType: ShareType!
    
    // MARK:- View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    

    // MARK:- IBAction methods
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        if let delegate = delegate {
            dismiss(animated: true, completion: {
                delegate.facebookSharePressed(type: self.shareType)
            })
        }
    }
    
}




