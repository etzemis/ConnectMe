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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Call Method From Extension
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //*************************************************************
    //MARK: Perform LOGIN
    //*************************************************************

    @IBAction func LoginButtonTapped(_ sender: AnyObject) {
        let email = self.userEmail.text
        let password = self.userPassword.text

        //Check for Empty Fields
        if (email!.isEmpty || password!.isEmpty){
            //Display alert
            displayAlertMessage(message: "All Fields are required")
            return
        }
        
        //dismiss the keyboard
        view.endEditing(true)
        
        //present spinner :-)
        Spinner.sharedInstance.show(uiView: (self.navigationController?.view)!)
        
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            ServerAPIManager.sharedInstance.login(email: email!,
                                                  password: password!)
            {
                result in
                //stop spinner in main thread!
                DispatchQueue.main.async {
                    Spinner.sharedInstance.hide(uiView: (self.navigationController?.view)!)
                }
                
                //if encountered an error
                guard result.error == nil else {
                    print(result.error!)
                    let errorMessage: String?
                    
                    switch result.error! {
                    case ServerAPIManagerError.apiProvidedError:
                        errorMessage = "Invalid Credentials. Please try again."
                    default:  //objectSerialization, 500
                        errorMessage = "Sorry, login could not be completed. Please try again."
                    }
                    
                    let alertController = UIAlertController(title: "Login Failed", message: errorMessage,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                if let res = result.value {
                    
                    let token  = res["token"]!
                    print("\n\n\n Token is \(token)")
                    //if Registration is complete then Save Results and dismiss View Controler
                    DispatchQueue.main.async {
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: AppConstants.HandleUserLogIn.IsUserLoggedInUserDefaults)
                        defaults.set(email!, forKey: AppConstants.HandleUserLogIn.UsernameUserDefaults)
                        defaults.set(token, forKey: AppConstants.HandleUserLogIn.PasswordTokenUserDefaults)
                        let nickname = res["username"]!
                        defaults.set(nickname, forKey: AppConstants.HandleUserLogIn.nicknameUserDefaults)
                        let imageUrl = res["imageUrl"]!
                        defaults.set(imageUrl, forKey: AppConstants.HandleUserLogIn.imageUrlUserDefaults)
                        defaults.synchronize()
                        
                        //Set Flag to allow Connectivity
                        DataHolder.sharedInstance.startAllConnections()

                        self.dismiss(animated: true, completion: nil)
                    }
                }
                return

            }
        }
    }
    
    //*************************************************************
    //MARK: Display Alert Messages
    //*************************************************************

    func displayAlertMessage(message: String) {
        let alert = UIAlertController(title: "Login Denied", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        return
    }
    
}



