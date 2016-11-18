//
//  TravellersTVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 20/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import CoreLocation

class TravellersTVC: UITableViewController {
    
    //*************************************************************
    //MARK: Variables for storing Travellers
    //*************************************************************

    private var selectedTravellers: [Traveller] = []
    private var suggestedTravellers: [Traveller] = []
    {
        didSet{
            calculateTravellersByProximity()
            tableView.reloadData()
        }
    }
    private var SegueDueToInvitation = false
    
    private var highProximityTravellers: [Traveller] = []
    private var mediumProximityTravellers: [Traveller] = []
    private var lowProximityTravellers: [Traveller] = []

    private func calculateTravellersByProximity(){
        highProximityTravellers.removeAll()
        mediumProximityTravellers.removeAll()
        lowProximityTravellers.removeAll()
        
        for t in suggestedTravellers{
            switch t.proximity{
            case 0:
                highProximityTravellers.append(t)
            case 1:
                mediumProximityTravellers.append(t)
            default:
                lowProximityTravellers.append(t)
            }
            
        }
    }
    
    struct Constants {
        static let CellIdentifier = "Traveller Cell"
        static let AwaitConfirmationSegue = "Wait for Traveller Confirmation"
    }

    
    //*************************************************************
    //MARK: ViewController Lifecycle
    //*************************************************************

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SetUp Navigation Bar
        self.navigationItem.title = "Travellers"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendInvitation(_:))), animated: true)
        self.navigationItem.setHidesBackButton(true, animated:true);
        //set Toolbar

        var items = [UIBarButtonItem]()

        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(title: "Change Destination", style: .plain, target: self, action: #selector(dismissToChangeDestination))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        self.toolbarItems = items

        
        //SetUp TableView Appearence
        tableView.allowsMultipleSelection = false
        
        
        //add Refresh Control for pull to refresh
        if (self.refreshControl == nil) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self,
                                           action: #selector(refresh(sender:)),
                                           for: .valueChanged) }
        
        //fetch Users
        self.refresh(sender: self)


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        
        // Activate Trip DataHolder
        TripDataHolder.sharedInstance.startAllConnections()
        

        

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.InvitationToTripReceived), object: nil)
    }
    
    @objc func dismissToChangeDestination(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnInvitationToTrip),
                                               name: NSNotification.Name(AppConstants.NotificationNames.InvitationToTripReceived), object: nil)
        
        TripDataHolder.sharedInstance.startListeningForInvitations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.InvitationToTripReceived), object: nil)

        TripDataHolder.sharedInstance.stopListeningForInvitations()
    }
    

 
    
    //*************************************************************
    //MARK: Create Ivitation
    //*************************************************************

   
   @objc func sendInvitation(_ sender: AnyObject){
        
        //Clear Suggested Array
        selectedTravellers.removeAll()
        //Calculate Travellers from Cells
        for i in stride(from: 0, to: tableView.numberOfSections, by: 1)
        {
            for j in stride(from: 0, to: tableView.numberOfRows(inSection: i), by: 1)
            {
                let cell = tableView.cellForRow(at: IndexPath.init(row: j, section: i))
            
                if cell!.accessoryType == .checkmark
                {
                    var user: Traveller
                    switch i{
                    case 0:
                        user = highProximityTravellers[j]
                    case 1:
                        user = mediumProximityTravellers[j]
                    default:
                        user = lowProximityTravellers[j]
                    }
                    selectedTravellers.append(user)
                }
            }
        }
        if(!selectedTravellers.isEmpty)
        {
            if (tripHasValidNumberOfPersons()){
                showCreatedTripAlert(travellers: selectedTravellers)
            }
            else{
                let confirmationAlert = UIAlertController(title: "Trip Creation Invalid",
                                                          message: "You have exceeded the maximum number (4) of persons than can be in the same trip.",
                                                          preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                confirmationAlert.addAction(confirmAction)
                self.present(confirmationAlert, animated: true, completion: nil)

            }
        }

      
    }
    
    
    private func tripHasValidNumberOfPersons() -> Bool{
        let noPersons = selectedTravellers.reduce(DataHolder.sharedInstance.userLoggedIn.extraPersons + 1)
        {
           (result, t2) in result + t2.extraPersons + 1
        }
        return noPersons <= 4
    }
    
    
    
    
    //*************************************************************
    //MARK: Trip Creation  Remote
    //*************************************************************

    
    var autoInvitationRejectionTimer = Timer()
    func showCreatedTripAlert(travellers: [Traveller])
    {
        
        //create message
        var i = 1
        var message = "The following users will be invited:"
        for traveller in travellers
        {
            message.append("\n\n")
            message.append("\(i). \(traveller.name.capitalized) \t -->  \(traveller.destination.region!) \t~100")
            i += 1
        }
        
        //create Alert
        let confirmationAlert = UIAlertController(title: "Trip Confirmation",
                                                  message: message,
                                                  preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default)
        {
            _ in
            self.sendTripInvitationRemote(travellers: travellers)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    
    func sendTripInvitationRemote(travellers: [Traveller])
    {
        Spinner.sharedInstance.show(uiView: self.view)
        
        let travellerEmails = travellers.map {$0.email}
        
        
        ServerAPIManager.sharedInstance.createTripRequest(travellers: travellerEmails)
        {
            result in
            //if encountered an error
            guard result.error == nil else {
                print(result.error!)
                let errorMessage: String?
                
                switch result.error! {
                case ServerAPIManagerError.apiProvidedError:
                    errorMessage = "You have already been invited to join a Trip"
                default: // general error 500
                    errorMessage = "Please check your internet connection and try again."
                }
                
                
                let alertController = UIAlertController(title: "Trip Cretion Failed", message: errorMessage,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                DispatchQueue.main.async {
                    //stop spinner
                    Spinner.sharedInstance.hide(uiView: self.view)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            //if Trip Creation is complete
            DispatchQueue.main.async {
                
                //filter Selected Users to Match the ones returned from The Server
                
                let filteredTravellers = self.selectedTravellers.filter{ result.value!.contains($0.email)}
                self.selectedTravellers = filteredTravellers
                
                //stop spinner
                Spinner.sharedInstance.hide(uiView: self.view)
                
                self.SegueDueToInvitation = false
                self.performSegue(withIdentifier: Constants.AwaitConfirmationSegue, sender: self)
                
            }
            return
        }
    }
    
    //*************************************************************
    //MARK: Invitation to Trip
    //*************************************************************

    @objc func actOnInvitationToTrip(){
        //enable it again after our response
        TripDataHolder.sharedInstance.stopListeningForInvitations()
        
        
        self.autoInvitationRejectionTimer = Timer.scheduledTimer(timeInterval: 5,
                                                                 target: self,
                                                                 selector: #selector(autoRejectInvitation),
                                                                 userInfo: nil,
                                                                 repeats: false)
        
        showInvitedTripAlert(travellers: TripDataHolder.sharedInstance.travellersInInvitation)
    }
    
    @objc func autoRejectInvitation(){
        DispatchQueue.main.async {
            //dismiss alert
            self.dismiss(animated: true, completion: nil)
            //present Spinner
            Spinner.sharedInstance.show(uiView: self.view)
        }
        sendResponse(isAccepted: false)
    }
    
    func showInvitedTripAlert(travellers: [Traveller]){
        
        //create message
        var i = 1
        var message = "You have been invited to join a Trip:"
        for traveller in travellers{
            message.append("\n\n")
            if i==1
            {
                message.append("Creator:\n\n")
                message.append("\(i). \(traveller.name.capitalized) \t -->  \(traveller.destination.region!) \t~100")
            }
            else
            {
                if i==2
                {
                    message.append("Co-Travellers:\n\n")
                }
                message.append("\(i). \(traveller.name.capitalized) \t -->  \(traveller.destination.region!) \t~100")
            }
            i += 1
        }
        
        //create Alert
        let confirmationAlert = UIAlertController(title: "Trip Invitation",
                                                  message: message,
                                                  preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Accept", style: .default)
        {
            _ in
            
            //cancel the auto rejection
            self.autoInvitationRejectionTimer.invalidate()
            
            DispatchQueue.main.async { // Start Spinner
                Spinner.sharedInstance.show(uiView: self.view)
            }
            self.sendResponse(isAccepted: true)

        }
        let cancelAction = UIAlertAction(title: "Reject", style: .default)
        {
            _ in
            
            //cancel the auto rejection
            self.autoInvitationRejectionTimer.invalidate()
            
            DispatchQueue.main.async {
                Spinner.sharedInstance.show(uiView: self.view)
            }
            self.sendResponse(isAccepted: false)
        }
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
    }
    

    func sendResponse(isAccepted: Bool) {
        if isAccepted
        {
            ServerAPIManager.sharedInstance.respondToTripRequest(accepted: isAccepted)
            {
                result in
                guard result.error == nil else {
                    self.handleResponseToInvitationError(result.error!)
                    self.sendResponse(isAccepted: isAccepted)
                    return
                }
                // We DO NOT need to start listening again for invitations
                DispatchQueue.main.async {
                    Spinner.sharedInstance.hide(uiView: self.view)
                    self.SegueDueToInvitation = true
                    self.performSegue(withIdentifier: Constants.AwaitConfirmationSegue, sender: self)
                }
                
            }
        }
        else
        {
            ServerAPIManager.sharedInstance.respondToTripRequest(accepted: isAccepted)
            {
                result in
                guard result.error == nil else {
                    self.handleResponseToInvitationError(result.error!)
                    self.sendResponse(isAccepted: isAccepted)
                    return
                }
                
                DispatchQueue.main.async {
                    Spinner.sharedInstance.hide(uiView: self.view)
                    //enable it again after our response
                    TripDataHolder.sharedInstance.startListeningForInvitations()
                }
                
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
    //MARK: Pull to Refresh
    //*************************************************************

    
    @objc func refresh(sender: Any) {

        ServerAPIManager.sharedInstance.fetchTravellersAroundMeTrip
        {
            result in
            guard result.error == nil else {
                self.handleFetchTravellersTravellersAroundMeTripError(result.error!)
                return
            }
            if let fetchedTravellers = result.value
            {
                DispatchQueue.main.async
                {      //Avoid Race Conditions
                    
                    if self.refreshControl != nil,
                        self.refreshControl!.isRefreshing
                    {
                        self.refreshControl?.endRefreshing()
                    }
                    self.suggestedTravellers = fetchedTravellers
                }
            }
        }
    }
   
    private func handleFetchTravellersTravellersAroundMeTripError(_ error: Error) {
        switch error{
        case ServerAPIManagerError.authLost:
            DataHolder.sharedInstance.handleLostAuthorisation()
        case ServerAPIManagerError.network:
            break
        case ServerAPIManagerError.objectSerialization:
            break
        case ServerAPIManagerError.apiProvidedError:
            break
        default:
            debugPrint("handleFetchTravellersTravellersAroundMeError -->  UNKNOWN Error")
        }
        
        debugPrint("handleLoadTravellersError: LoadTravellers Error")
    }
    
    
    
    //*************************************************************
    //MARK: Table View Delegate
    //*************************************************************

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return highProximityTravellers.count
        case 1:
            return mediumProximityTravellers.count
        default:
            return lowProximityTravellers.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath) as! TravellerCell
        
        var user: Traveller
        switch indexPath.section {
        case 0:
            user = highProximityTravellers[indexPath.row]
        case 1:
            user = mediumProximityTravellers[indexPath.row]
        default:
            user = lowProximityTravellers[indexPath.row]
        }
        
        cell.traveller = user
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath){
            if cell.accessoryType == .checkmark
            {
                cell.accessoryType = .none
            } else
            {
                cell.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "High Proximity (Within 1km)"
        case 1:
            return "Medium Proximity (Within 2km)"
        default:
            return "Low Proximity (More than 2km)"
        }
    }

    
    //*************************************************************
    //MARK: Navigation
    //*************************************************************

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Constants.AwaitConfirmationSegue
        {
                if let awaitTravTVC = segue.destination as? AwaitTravellersTVC
                {

                    if SegueDueToInvitation
                    {
                        //set the mode and the travellers
                        awaitTravTVC.tripMode = .Invited
                        awaitTravTVC.travellers = TripDataHolder.sharedInstance.travellersInInvitation
                        //Set the back button to have no title
                        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                    }
                    else
                    {
                        //set the mode and the travellers
                        awaitTravTVC.tripMode = .Created
                        awaitTravTVC.travellers = selectedTravellers
                        //Set the back button to have no title
                        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                    }

                }
            
        }
    }


    
    private func handleLostAuthorisation()
    {
        DataHolder.sharedInstance.handleLostAuthorisation()
    }
    


}
