//
//  ViewController.swift
//  yuLocate
//
//  Created by Yenkay on 06/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var yuDb = YuLocate.getInstance()
    
    @IBOutlet var pinTxt: UITextField!
    
    @IBOutlet var loginBtn: UIButton!
    
    @IBOutlet var createBtn: UIButton!
    
    @IBAction func tappedOutside(sender: UITapGestureRecognizer) {
        pinTxt.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        pinTxt.text = ""
        if(yuDb.getUserCount() > 0) {
            createBtn.hidden = true
            loginBtn.hidden = false
        } else {
            loginBtn.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        navigationController?.performSegueWithIdentifier("go2home2", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        yuDb.dblog("Segue \(segue.identifier)")
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var flag = false
        pinTxt.resignFirstResponder()
        if(identifier == "go2home2") {
            if(pinTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
                YuLocateClientHelper.alert("PIN can't be empty", controller: self)
            } else if (yuDb.isUserPINValid(pinTxt.text)) {
                flag = true
            } else {
                YuLocateClientHelper.alert("PIN is invalid", controller: self)
                flag = false
            }
        } else if(identifier == "go2create") {
            flag = true
        }
        return flag
    }
}