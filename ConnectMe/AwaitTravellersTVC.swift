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
        static let StartTripSegueIdentifier = "Start Trip"
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
        
        
        TripRequestDataHolder.sharedInstance.startRefreshingStatus()
        //Listen for Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTripStatusChanged),
                                               name: NSNotification.Name(AppConstants.NotificationNames.TripRequestTripStatusChanged), object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTravellerStatusChanged),
                                               name: NSNotification.Name(AppConstants.NotificationNames.TripRequestTravellerStatusChanged), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        TripRequestDataHolder.sharedInstance.stopRefreshingStatus()
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
    //MARK: Act On Status change
    //*************************************************************

    @objc func actOnTripStatusChanged(){
        switch TripRequestDataHolder.sharedInstance.tripStatus
        {
        case .waiting:
            break
        case .cancelled:
            actOnTripWasCancelled()
            break
        case .started:
            actOnTripHasStarted()
            break
        }
    }
    
    
    @objc func actOnTravellerStatusChanged(){
        if TripRequestDataHolder.sharedInstance.tripStatus != .cancelled{
            self.tableView.reloadData()
        }
    }
    
    
    //*************************************************************
    //MARK: Act On Trip Cancelled
    //*************************************************************
    
    private func actOnTripWasCancelled()
    {
        
        //Navigate back to TravellersVC
        let confirmationAlert = UIAlertController(title: "Trip Cancellation",
                                                  message: "Trip Has ben Cancelled from the Creator! You may create a new one if you wish to",
                                                  preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default)
        {
            _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        confirmationAlert.addAction(confirmAction)
        self.present(confirmationAlert, animated: true, completion: nil)

    }
    
    //*************************************************************
    //MARK: Act On Trip Started
    //*************************************************************
    
    private func actOnTripHasStarted()
    {
        //Stop All connections for Trip Request
        TripRequestDataHolder.sharedInstance.stopAllConnections()
        
        performSegue(withIdentifier: Constants.StartTripSegueIdentifier, sender: self)
        
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
                Spinner.sharedInstance.show(uiView: (self.navigationController?.view)!)
            }
            self.sendCancelTrip()
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    
    func sendCancelTrip() {
        ServerAPIManager.sharedInstance.cancelTripRequest
        {
            result in
            guard result.error == nil else {
                self.handleSendCancelTripError(result.error!)
                return
            }
            DispatchQueue.main.async {
                Spinner.sharedInstance.hide(uiView: (self.navigationController?.view)!)
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    
    func handleSendCancelTripError(_ error: Error) {
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
        let (userToDisplay, hasAccepted) = getUser(forIndexPath: indexPath)
        cell.setTraveller(traveller: userToDisplay, hasAlreadyAccepted: hasAccepted)
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

    func getUser(forIndexPath indexPath: IndexPath) -> (Traveller, Bool){
        if indexPath.section == 0 {
            return (DataHolder.sharedInstance.userLoggedIn, true)
        }
        if indexPath.section == 1 {
            switch tripMode {
            case .Created:
                return (travellers[indexPath.row], false) // has not said yes
            default:
                return (travellers[0], true)
            }
        }
        else{
            return (travellers[indexPath.row + 1], false)
        }
    }
    
    private func handleLostAuthorisation()
    {
        DataHolder.sharedInstance.handleLostAuthorisation()
    }
    


}
