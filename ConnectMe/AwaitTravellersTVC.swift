//
//  AwaitTravellersTVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 10/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//


import UIKit

class AwaitTravellersTVC: UITableViewController {

    
    //*************************************************************
    //MARK: Trip Request Constants
    //*************************************************************

    struct Constants {
        static let CellIdentifier = "Traveller Status Cell"
    }
    
    enum Trip {
        case Invited
        case Created
        
        func sections() -> Int{
            switch self {
            case .Created:
                return 2
            default:
                return 3
            }
        }
        
        func nameForSection(section: Int) -> String {
            switch self {
            case .Created:
                let array = ["Creator", "Travellers"]
                return array[section]
            default:
                let array = ["You", "Creator", "Travellers"]
                return array[section]
            }
        }
    }
    var tripMode: Trip = .Created
    var travellers: [Traveller] = [];
    
    
    private var countDowntime = 120 // in seconds
    private var timer = Timer()
    

    


    //*************************************************************
    //MARK: Application Lifecycle & Countdown
    //*************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        //set Toolbar
        
        var items = [UIBarButtonItem]()
        
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(title: "Cancel Trip", style: .plain, target: self, action: #selector(cancelTrip))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        self.toolbarItems = items


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show The Toolbar
        self.navigationController?.isToolbarHidden = false
    }
    
    // Use it for the CountDown
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //Timer
    @objc func updateTimer(){
        self.navigationItem.title = "Remaining time: \(self.countDowntime) s"
        if( self.countDowntime == 0) {
            self.timer.invalidate()
        }
        self.countDowntime -= 1
    }


    //*************************************************************
    //MARK: Cancel Trip
    //*************************************************************

    @objc func cancelTrip(){
        showCancelTripAlert()
    }

    
    func showCancelTripAlert(){
        var message = ""
        switch self.tripMode{
        case .Created:
            message = "Are you sure you want to cancel the trip? All invited travellers will be pulled out of the trip"
            break
        default:
            message = "Are you sure you want to pull out from the trip?"
        }
        
        //create Alert
        let confirmationAlert = UIAlertController(title: "Trip Cancellation",
                                                  message: message,
                                                  preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Pull out", style: .default)
        {
            _ in
            DispatchQueue.main.async { // Start Spinner
                Spinner.sharedInstance.show(uiView: self.view)
            }
            self.sendResponse()
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    
    func sendResponse() {
        ServerAPIManager.sharedInstance.cancelTripRequest
        {
            result in
            guard result.error == nil else {
                self.handleResponseToInvitationError(result.error!)
                self.sendResponse()
                return
            }
            // We DO NOT need to start listening again for invitations
            DispatchQueue.main.async {
                Spinner.sharedInstance.hide(uiView: self.view)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    
    func handleResponseToInvitationError(_ error: Error) {
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        default:  // network
            return
        }
        debugPrint("HandleUpdateLocationError: updateLocation error")
    }

    
    
    
    
    //*************************************************************
    //MARK: Table View Data Source
    //*************************************************************

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tripMode.sections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            switch tripMode {
            case .Created:
                return travellers.count
            default:
                return 1
            }
        }
        else{
            return travellers.count - 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath) as! TravellerStatusCell
        cell.traveller = getUser(forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "You"
        }
        if section == 1 {
            switch tripMode {
            case .Created:
                return "Travellers"
            default:
                return "Creator"
            }
        }
        else{
            return "Travellers"
        }

    }
    

    

    //*************************************************************
    //MARK: Helper Functions
    //*************************************************************

    func getUser(forIndexPath indexPath: IndexPath) -> Traveller{
        if indexPath.section == 0 {
            return DataHolder.sharedInstance.userLoggedIn
        }
        if indexPath.section == 1 {
            switch tripMode {
            case .Created:
                return travellers[indexPath.row]
            default:
                return travellers[0]
            }
        }
        else{
            return travellers[indexPath.row + 1]
        }
    }
    
    private func handleLostAuthorisation()
    {
        DataHolder.sharedInstance.handleLostAuthorisation()
    }
    


}
