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
    
    // add users when you create a trip
    private var selectedTravellers: [Traveller] = []
    private var suggestedTravellers: [Traveller] = []
    
    struct Constants {
        static let CellIdentifier = "Traveller Cell"
        static let AwaitConfirmationSegue = "Wait for Traveller Confirmation"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SetUp Navigation Bar
        self.navigationItem.title = "Travellers"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendInvitation(_:))), animated: true)
        
        //SetUp TableView Appearence
        tableView.allowsMultipleSelection = false
        
        //Create Bot Users
        suggestedTravellers = createBotUsers()
        
        //add Refresh Control for pull to refresh
        if (self.refreshControl == nil) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self,
                                           action: #selector(refresh(sender:)),
                                           for: .valueChanged) }


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
//MARK: SendInvitation
    @objc func sendInvitation(_ sender: AnyObject){
        
        //Clear Suggested Array
        selectedTravellers.removeAll()
        //Calculate Travellers from Cells
        for i in stride(from: 0, to: tableView.numberOfRows(inSection: 0), by: 1) {
            let cell = tableView.cellForRow(at: IndexPath.init(row: i, section: 0))
            if cell!.accessoryType == .checkmark {
                let user = suggestedTravellers[i]
                selectedTravellers.append(user)
            }
        }
        //present ConfirmationAlert
        showCreatedTripAlert(travellers: selectedTravellers)
//         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
//            self.showTripConfirmationAlert(travellers: self.selectedTravellers)
//        }
    
      
    }
    
    func showCreatedTripAlert(travellers: [Traveller]){
        
        //create message
        var i = 1
        var message = "The following users will be invited:"
        for traveller in travellers{
            message.append("\n\n")
            message.append("\(i). \(traveller.name.capitalized) \t -->  \(traveller.destination.region!) \t~100")
            i += 1
        }
        
        //create Alert
        let confirmationAlert = UIAlertController(title: "Trip Confirmation",
                                                  message: message,
                                                  preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default){
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
            if i==1 {
                message.append("Creator:\n\n")
                message.append("\(i). \(traveller.name.capitalized) \t -->  \(traveller.destination.region!) \t~100")
            }
            else{
                if i==2{
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
        let confirmAction = UIAlertAction(title: "Accept", style: .default){
            _ in
            self.performSegue(withIdentifier: Constants.AwaitConfirmationSegue, sender: self)
        }
        let cancelAction = UIAlertAction(title: "Reject", style: .default, handler: nil)
        
        confirmationAlert.addAction(confirmAction)
        confirmationAlert.addAction(cancelAction)
        
        self.present(confirmationAlert, animated: true, completion: nil)
        
    }
    

// MARK: - Pull to Refresh
    @objc func refresh(sender: Any) {
//        ServerAPIManager.sharedInstance.clearCache()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            if self.refreshControl != nil,
                self.refreshControl!.isRefreshing
            {
                self.refreshControl?.endRefreshing()
            }
        }


        
    }
    
// MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedTravellers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath) as! TravellerCell
        let user = suggestedTravellers[indexPath.row]
        cell.traveller = user
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
            
        }
    }
    
//MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.AwaitConfirmationSegue{
        
                if let awaitTravTVC = segue.destination as? AwaitTravellersTVC {
                    //set the mode and the travellers
                    awaitTravTVC.tripMode = .Created
                    awaitTravTVC.travellers = selectedTravellers
                    //Set the back button to have no title
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                }
            
        }
    }



    func createBotUsers() -> [Traveller]{
        var users = [Traveller]()
        
        var user = Traveller(name: "Vaggelis",
                        destination: Location(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877),
                        imageUrl: "http://192.168.1.91:3000/photo2.jpg" )
        users.append(user)
        
        user = Traveller(name: "Petros",
                    destination: Location(address: "Ermou 83-85", region: "Athens", coord: CLLocationCoordinate2D(latitude: 37.976648, longitude: 23.726223)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367),
                    imageUrl: "http://192.168.1.91:3000/photo1.jpg")
        users.append(user)
        
        user = Traveller(name: "Hercules",
                    destination: Location(address: "Andromachis 237", region: "Pireas", coord: CLLocationCoordinate2D(latitude: 37.941077, longitude: 23.670781)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.985240, longitude: 23.680818))
        users.append(user)
        

    
        return users
    }


}
