//
//  DataHolder.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 02/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import UIKit

/// Holds All the connectiosn for the App While not in a Trip
/// Registration and Logging In are on thei respective View Controllers
/// Trip MAnagement is inside TripDataHolder.swift file
class DataHolder{
    static let sharedInstance = DataHolder()
    
    var travellers: [Traveller] = [] {
        didSet{
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.TravellersAroundMeUpdated), object: self)
        }
    }

    // MARK: Load Travellers Remote
    func loadTravellers(){
        ServerAPIManager.sharedInstance.fetchTravellersAroundMe{
            result in
            guard result.error == nil else {
                self.handleLoadTravellersError(result.error!)
                return
            }
            if let fetchedTravellers = result.value {
                self.travellers = fetchedTravellers
            }
        }
    }
    
    func handleLoadTravellersError(_ error: Error) {
        //TODO: Show Error
        debugPrint("handleLoadTravellersError: LoadTravellers Error")
    }


    
//MARK: Update User Location
    func updateLocation(location: Location){
        ServerAPIManager.sharedInstance.updateLocation(location: location){
            result in
            guard result.error == nil else {
                self.handleUpdateLocationError(result.error!)
                return
            }
            debugPrint("DataHolder: updateLocation successful")
        }
    }
    
    func handleUpdateLocationError(_ error: Error) {
        //TODO: Show Error
        debugPrint("HandleUpdateLocationError: updateLocation error")
    }
    
    
//MARK: Stop All Connectivity
    func stopAllConnections(){
        
    }
    
}
