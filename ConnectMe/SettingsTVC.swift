//
//  SettingsTVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 26/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {

    @IBAction func logoutUser(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "User Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Logout", style: .default){ action in
            UserDefaults.standard.set(false, forKey: AppDelegate.Constants.IsUserLoggedInUserDefaults)
            UserDefaults.standard.synchronize()
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func closeSettings(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)    
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
