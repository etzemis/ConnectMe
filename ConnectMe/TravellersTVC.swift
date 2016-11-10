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
        static let StartNavigationSegue = "Start Navigation"
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
    
    @objc func sendInvitation(_ sender: AnyObject){
      performSegue(withIdentifier: Constants.StartNavigationSegue, sender: sender)
    }

// MARK: - Pull to Refresh
    @objc func refresh(sender: Any) {
//        ServerAPIManager.sharedInstance.clearCache()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            if self.refreshControl != nil,
                self.refreshControl!.isRefreshing
            {
                self.refreshControl?.endRefreshing()
            }
        }


        
    }
    
// MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
