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
    @IBOutlet weak var userPasswordRetype: UITextField!
    @IBOutlet weak var userAddress: UITextField!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: View Controller Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        // set empty Profile Image
        setCircularImage()
    }
    
    //MARK: IBActions
    
    @IBAction func CancelRegistrationAndLogin(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func CaptureUserImageTapped(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            noCameraALert()
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: AnyObject) {
        let name = self.userName.text
        let email = self.userEmail.text
        let password = self.userPassword.text
        let address = self.userAddress.text
        let profileImage: UIImage? = nil
        
        //Check for Empty Fields
        if (name!.isEmpty || email!.isEmpty || password!.isEmpty || address!.isEmpty){
            //Display alert
            displayAlertMessage(message: "All Fields are required")
            return
        }
        
        //Will not be happening here!!
        //Store Data
        let defaults  = UserDefaults.standard
        defaults.set(name,  forKey: AppDelegate.Constants.UsernameUserDefaults)
        defaults.set(email, forKey: AppDelegate.Constants.EmailUserDefaults)
        defaults.set(password, forKey: AppDelegate.Constants.PasswordUserDefaults)
        defaults.set(address, forKey: AppDelegate.Constants.AddressUserDefaults)
        
        //present spinner :-)
        Spinner.sharedInstance.show(uiView: self.view)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {

        
        ServerAPIManager.sharedInstance.register(username: name!,
                                                 email: email!,
                                                 password: password!,
                                                 profileImage: profileImage,
                                                 address: address!)
        {
            result in
            //stop spinner in main thread!
            DispatchQueue.main.async {
                 Spinner.sharedInstance.hide(uiView: self.view)
            }
            
            //if encountered an error
            guard result.error == nil else {
                print(result.error!)
                let errorMessage: String?
                
                switch result.error! {
                case ServerAPIManagerError.apiProvidedError, ServerAPIManagerError.network:
                    errorMessage = "Sorry, there was an error in connecting with the server. Please check your internet connection and try again."
                default:
                    errorMessage = "Sorry, registration could not be completed. Please try again."
                }
                
 
                let alertController = UIAlertController(title: "Could not complete registration", message: errorMessage,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            //if Registration is complete
            DispatchQueue.main.async {
                self.registrationSucceededAlert()
            }
            return
        }
        }
    }
    
    func registrationSucceededAlert(){
        //Display alert message with Comfirmation
        
        let alert = UIAlertController(title: "User Registration Successful", message: "Your Account has been successfully created. Please Login to Start Using the Application", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {
            action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Private Functions
    
    private func setCircularImage(){
        userProfileImage.image =  UIImage(named: "empty_profile")
        userProfileImage.layer.cornerRadius = 50
        userProfileImage.clipsToBounds = true
        userProfileImage.layer.borderWidth = 1
        userProfileImage.layer.borderColor = UIColor.lightText.cgColor
    }

    // MARK: Validation
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK: Alert Messages     //Lecture 15 35:00
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(title: "User Registration Incomplete", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func noCameraALert(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default,handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        userProfileImage.contentMode = .scaleAspectFill //3
        userProfileImage.image = chosenImage //4
        dismiss(animated:true, completion: nil) //5
        
        addPhotoButton.titleLabel?.text = "Edit Photo"
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.placeholder! {
        case "  Username":
            textField.resignFirstResponder()
            userPassword.becomeFirstResponder()
        case "  Password":
            textField.resignFirstResponder()
            userPasswordRetype.becomeFirstResponder()
        case "  Retype Password":
            if userPassword.text == userPasswordRetype.text {
                textField.resignFirstResponder()
                userEmail.becomeFirstResponder()
            }
            else{
                displayAlertMessage(message: "Passwords do not match.")
                return false
            }
        case "  Email Address":
            if isValidEmail(testStr: textField.text!) {
                textField.resignFirstResponder()
                userAddress.becomeFirstResponder()
            }
            else{
                displayAlertMessage(message: "E-mail is not valid.")
                return false
            }
        case "  Address":
            textField.resignFirstResponder()
        default:
            resignFirstResponder()
        }
        return true
    }

}
