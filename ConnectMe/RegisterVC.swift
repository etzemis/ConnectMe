//
//  RegisterVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 26/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userAddress: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func CaptureUserImageTapped(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            noCamera()
        }
}


    @IBAction func registerButtonTapped(_ sender: AnyObject) {
        let name = self.userName.text
        let email = self.userEmail.text
        let password = self.userPassword.text
        let address = self.userAddress.text
        
        //Check for Empty Fields
        if (name!.isEmpty || email!.isEmpty || password!.isEmpty || address!.isEmpty){
            //Display alert
            displayAlertMessage(message: "All Fields are required")
            return
        }
        //Store Data
        //Dispaly alert message with Comfirmation
    }
    
    // MARK: Validation
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK: Alert Messages
    
    //Lecture 15 35:00
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(title: "User Registration Incomplete", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default,handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.placeholder! {
        case "Username":
            textField.resignFirstResponder()
            userEmail.becomeFirstResponder()
        case "Email Address":
//            if isValidEmail(testStr: textField.text!) {
                textField.resignFirstResponder()
                userPassword.becomeFirstResponder()
//            }
//            else{
//                displayAlertMessage(message: "E-mail is not valid.")
//                return false
//            }
        case "Password":
            textField.resignFirstResponder()
            userAddress.becomeFirstResponder()
        case "Address":
            textField.resignFirstResponder()
        default:
            resignFirstResponder()
        }
        return true
    }

}
