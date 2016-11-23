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
    
    private var hasSelectedImage = false
    

    //*************************************************************
    //MARK: View Controller Lifecicle
    //*************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        // set empty Profile Image
        setCircularImage()
        //Call Method From Extension
        self.hideKeyboardWhenTappedAround()
    }

    //*************************************************************
    //MARK: IBActions
    //*************************************************************

    
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
    
    
    //*************************************************************
    //MARK: Perform Registration
    //*************************************************************

    @IBAction func registerButtonTapped(_ sender: AnyObject) {
        let name = self.userName.text
        let email = self.userEmail.text
        let password = self.userPassword.text
        let address = self.userAddress.text
        let profileImage:UIImage? = !hasSelectedImage ? nil : userProfileImage.image!
        
        //Check for Empty Fields
        if (name!.isEmpty || email!.isEmpty || password!.isEmpty || address!.isEmpty){
            //Display alert
            displayAlertMessage(message: "All Fields are required")
            return
        }
        
        //present spinner :-)
        Spinner.sharedInstance.show(uiView: (self.navigationController?.view)!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {

        
        ServerAPIManager.sharedInstance.register(username: name!,
                                                 email: email!,
                                                 password: password!,
                                                 profileImage: profileImage,
                                                 address: address!)
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
                    errorMessage = "Email address already exists. Please either Login or use a unique email address."
                default: // general error 500
                    errorMessage = "Sorry, registration could not be completed. Please check your internet connection and try again."
                }
                
 
                let alertController = UIAlertController(title: "Registration Failed", message: errorMessage,
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
    

    
    //*************************************************************
    //MARK: Make Image Circular
    //*************************************************************

    
    private func setCircularImage(){
        userProfileImage.image =  UIImage(named: "empty_profile")
        userProfileImage.layer.cornerRadius = 50
        userProfileImage.clipsToBounds = true
        userProfileImage.layer.borderWidth = 1
        userProfileImage.layer.borderColor = UIColor.lightText.cgColor
    }

    
    //*************************************************************
    //MARK: Email Validation
    //*************************************************************

    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //*************************************************************
    //MARK: Alert Messages
    //*************************************************************

    
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
    
    //*************************************************************
    //MARK: UIImagePickerControllerDelegate
    //*************************************************************

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        userProfileImage.contentMode = .scaleAspectFill //3
        userProfileImage.image = chosenImage //4
        hasSelectedImage = true
        dismiss(animated:true, completion: nil) //5
        
        addPhotoButton.titleLabel?.text = "Edit Photo"
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //*************************************************************
    //MARK: TextField Delegate Methods
    //*************************************************************

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




