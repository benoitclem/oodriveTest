//
//  LoginViewController.swift
//  Testing
//
//  Created by Clément on 10/04/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    
    let netApi = oodNetApi.sharedInstance
    
    @IBOutlet weak var loginTF: NSTextField!
    @IBOutlet weak var pwdTF: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.titleVisibility = .hidden
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.styleMask.insert(.fullSizeContentView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func doLogin(_ sender: Any) {
        self.netApi.setCredentials(log: self.loginTF.stringValue, pwd: self.pwdTF.stringValue)
        netApi.me { rootObj, error  in
            if (error == nil) {
                NSLog("\(rootObj)")
                if let tabVC = self.parent as? NSTabViewController{
                    tabVC.selectedTabViewItemIndex = 1
                    let bVC = tabVC.childViewControllers[1] as! BrowsingViewController
                    bVC.root = rootObj
                    // here we should use a nice swifty var setter
                    bVC.trigReload()
                }
            } else {
                NSLog("error \(error?.code)")
                let alert = NSAlert()
                alert.messageText = "Could not log in"
                alert.informativeText = "The provided credentials may be incorrect"
                alert.alertStyle = NSAlertStyle.warning
                alert.addButton(withTitle: "Retry")
                alert.runModal()
            }
        }
        //self.view.window?.windowController?.close()
    }
}
