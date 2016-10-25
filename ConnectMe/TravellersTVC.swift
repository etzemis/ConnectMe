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
    private var selectedTravellers: [User] = []
    private var suggestedTravellers: [User] = []
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    @objc func sendInvitation(_ sender: AnyObject){
      performSegue(withIdentifier: Constants.StartNavigationSegue, sender: sender)
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

    
   //    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = self.tableView(tableView, cellForRowAt: indexPath)
//        if cell.accessoryType != .none {
//            cell.accessoryType = .none
//            return
//        }
//        cell.accessoryType = .checkmark
//        cell.backgroundColor = UIColor.white
//    }

    
//    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        let cell = self.tableView(tableView, cellForRowAt: indexPath)
//        if cell.accessoryType != .none {
//            cell.accessoryType = .none
//        }
//        else{
//            cell.accessoryType = .checkmark
//        }
//    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func createBotUsers() -> [User]{
        var users = [User]()
        
        var user = User(id: 1 as NSNumber, name: "Vaggelis",
                        destination: Destination(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
        users.append(user)
        
        user = User(id: 2 as NSNumber, name: "Petros",
                    destination: Destination(address: "Ermou 83-85", region: "Athens", coord: CLLocationCoordinate2D(latitude: 37.976648, longitude: 23.726223)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367))
        users.append(user)
        
        user = User(id: 3 as NSNumber, name: "Hercules",
                    destination: Destination(address: "Andromachis 237", region: "Pireas", coord: CLLocationCoordinate2D(latitude: 37.941077, longitude: 23.670781)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.985240, longitude: 23.680818))
        users.append(user)
        
        user = User(id: 4 as NSNumber, name: "Alexis",
                        destination: Destination(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
        users.append(user)
        
        user = User(id: 5 as NSNumber, name: "Jorgos",
                    destination: Destination(address: "Ermou 83-85", region: "Athens", coord: CLLocationCoordinate2D(latitude: 37.976648, longitude: 23.726223)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367))
        users.append(user)
        
        user = User(id: 6 as NSNumber, name: "Marvina",
                    destination: Destination(address: "Andromachis 237", region: "Pireas", coord: CLLocationCoordinate2D(latitude: 37.941077, longitude: 23.670781)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.985240, longitude: 23.680818))
        users.append(user)
        
        user = User(id: 7 as NSNumber, name: "Loula",
                        destination: Destination(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
        users.append(user)
        
        user = User(id: 8 as NSNumber, name: "Thanasis",
                    destination: Destination(address: "Ermou 83-85", region: "Athens", coord: CLLocationCoordinate2D(latitude: 37.976648, longitude: 23.726223)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367))
        users.append(user)
        
        user = User(id: 9 as NSNumber, name: "Giannis",
                    destination: Destination(address: "Andromachis 237", region: "Pireas", coord: CLLocationCoordinate2D(latitude: 37.941077, longitude: 23.670781)),
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
