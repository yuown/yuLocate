//
//  CreatePINController.swift
//  yuLocate
//
//  Created by Yenkay on 22/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class CreatePINController: UIViewController {
    
    let yuDb = YuLocate.getInstance()
    
    let clientAPI = YuLocateClientHelper.getInstance()
    
    @IBOutlet var txtPIN: UITextField!
    
    @IBOutlet var txtConfirmPIN: UITextField!
    
    var navController:UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedOutside(sender: UITapGestureRecognizer) {
        txtPIN.resignFirstResponder()
        txtConfirmPIN.resignFirstResponder()
    }
    
    @IBAction func createPINAction(sender: UIButton) {
        var message = ""
        if(txtPIN.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" || txtConfirmPIN.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
            message = "PIN/ Confirm PIN Can't be Empty"
        } else if(txtPIN.text != txtConfirmPIN.text) {
            message = "PIN and Confirm PIN don't match"
        }

        if(message != "") {
            YuLocateClientHelper.alert(message, controller: self)
        } else {
            yuDb.createUser("", pin: txtPIN.text)
            navController = self.parentViewController as UINavigationController
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func back2Login(sender: UIBarButtonItem) {
        navController = self.parentViewController as UINavigationController
        navController.popViewControllerAnimated(true)
    }
    
}
