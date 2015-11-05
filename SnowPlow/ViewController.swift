//
//  ViewController.swift
//  SnowPlow
//
//  Created by Mark on 11/4/15.
//  Copyright © 2015 MEB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var loginButton: UIButton!
    
    
    @IBAction func loginButtonTouchUpInside(sender: AnyObject) {
        
        if usernameTextField.text == "plow001" || usernameTextField.text == "plow002" {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isPlow")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isPlow")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isPlow")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

