//
//  LoginVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 26/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginButtonTapped(_ sender: AnyObject) {
        let defaults  = UserDefaults.standard
        let storedUserEmail = defaults.string(forKey: AppDelegate.Constants.EmailUserDefaults)
        let storedPassword = defaults.string(forKey: AppDelegate.Constants.PasswordUserDefaults)
        
        if (userEmail.text == storedUserEmail && userPassword.text == storedPassword){
            //Login Successful
            defaults.set(true, forKey: AppDelegate.Constants.IsUserLoggedInUserDefaults)
            defaults.synchronize()
            
            self.dismiss(animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Login Denied", message: "Incorrect E-mail or Password!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
