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
    //MARK: Application Lifecycle
    //*************************************************************

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SetUp Navigation Bar
        self.navigationItem.title = "Travellers"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendInvitation(_:))), animated: true)
        self.navigationItem.setHidesBackButton(true, animated:true);

        
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
        

    }
    
    deinit {
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

            showCreatedTripAlert(travellers: selectedTravellers)
        }

      
    }
    
    
    
    
    //*************************************************************
    //MARK: Trip Invitation - Creation Alerts
    //*************************************************************

    func showCreatedTripAlert(travellers: [Traveller]){
        
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
            self.performSegue(withIdentifier: Constants.AwaitConfirmationSegue, sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
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
            self.performSegue(withIdentifier: Constants.AwaitConfirmationSegue, sender: self)
        }
        let cancelAction = UIAlertAction(title: "Reject", style: .default, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
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
            return "High Proximity"
        case 1:
            return "Medium Proximity"
        default:
            return "Low Proximity"
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
                    //set the mode and the travellers
                    awaitTravTVC.tripMode = .Created
                    awaitTravTVC.travellers = selectedTravellers
                    //Set the back button to have no title
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                }
            
        }
    }


    


}
