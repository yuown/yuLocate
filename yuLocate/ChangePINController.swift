//
//  ChangePINController.swift
//  yuLocate
//
//  Created by Yenkay on 25/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class ChangePINController: UIViewController {
    
    @IBOutlet var currentPIN: UITextField!
    
    @IBOutlet var newPIN: UITextField!
    
    @IBOutlet var confirmNewPIN: UITextField!
    
    var yuDb = YuLocate.getInstance()
    
    var currentPINdb = ""
    
    var navController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPINdb = yuDb.getAllUsersFunc().1
    }
    
    @IBAction func changePIN(sender: UIButton) {
        var message = ""
        if(currentPIN.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" || newPIN.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" || confirmNewPIN.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
            message = "All the 3 fields are mandatory to Change PIN"
        } else if(currentPIN.text != currentPINdb) {
            message = "Current PIN is wrong, Remember!"
        } else if(newPIN.text != confirmNewPIN.text) {
            message = "New PIN doesn't match in the fields, Please match them to change successfully"
        }
        
        if(message != "") {
            YuLocateClientHelper.alert(message, controller: self)
        } else {
            yuDb.updatePIN(currentPIN.text, newPin: newPIN.text)
            navController = self.parentViewController as UINavigationController
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func tappedOutside(sender: UITapGestureRecognizer) {
        currentPIN.resignFirstResponder()
        newPIN.resignFirstResponder()
        confirmNewPIN.resignFirstResponder()
    }
}
