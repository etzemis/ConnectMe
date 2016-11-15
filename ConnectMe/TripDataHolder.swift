//
//  TripDataHolder.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 15/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import UIKit

/// Holds All the connectiosn for the App While not in a Trip
/// Registration and Logging In are on thei respective View Controllers
/// Trip MAnagement is inside TripDataHolder.swift file
class TripDataHolder{
    //MARK: Class variables
    static let sharedInstance = DataHolder()

    var isAllowedToConnect = true // Flag to stop all connections
    
    var travellers: [Traveller] = [] {
        didSet{
//            //Wiil be called from Main Thread so it is safe
//            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.TravellersAroundMeTripUpdated), object: self)
        }
    }
    

    
    
    
    //MARK: Stop All Connectivity
    func stopAllConnections(){
        self.isAllowedToConnect = false
    }
    
    func startAllConnections(){
        self.isAllowedToConnect = true
    }

}
