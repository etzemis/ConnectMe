//
//  TravellersTVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 20/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit

class TravellersTVC: UITableViewController {
    
    var travelers: [User] = []
    
    struct Constants {
        static let CellIdentifier = "Traveller Cell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Travellers"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendInvitation(_:))), animated: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc func sendInvitation(_ sender: AnyObject){
        print("invitation has been sent")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return travelers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)

        let user = travelers[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.destination.region
        return cell
    }
    
//override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let cell = self.tableView(tableView, cellForRowAt: indexPath)
//    if cell.accessoryType != .none {
//        cell.accessoryType = .none
//        return
//    }
//    cell.accessoryType = .checkmark
//
//}

    
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

}
