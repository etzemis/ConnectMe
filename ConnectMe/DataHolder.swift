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
//MARK: Class variables
    static let sharedInstance = DataHolder()
    
    let serialQueue = DispatchQueue(label: AppConstants.ServerConnectivity.serialqueue)

    var isAllowedToConnect = true // Flag to stop all connections

    var fetchTravellersAroundMeTimer = Timer()
    var travellers: [Traveller] = [] {
        didSet{
            //Wiil be called from Main Thread so it is safe
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.TravellersAroundMeUpdated), object: self)
        }
    }
    
// MARK: Insert Destination Remote
    func insertDestination(destination: Location, extraPersons: Int){
        if(self.isAllowedToConnect){
            serialQueue.async{
                ServerAPIManager.sharedInstance.insertDestination(destination: destination, extraPersons: extraPersons) {
                    result in
                    guard result.error == nil else {
                        self.handleInsertDestinationError(result.error!)
                        //send Failed Notification
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.DestinationFailedToUpdate), object: self)
                        }
                        return
                    }
                    //send success Notification
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.DestinationUpdatedSuccessfuly), object: self)
                    }
                }
            }
        }
    }
    
    func handleInsertDestinationError(_ error: Error) {
        //TODO: Show Error
        debugPrint("HandleUpdateLocationError: updateLocation error")
    }
    
    

// MARK: Fetch Travellers Remote
    
    func startFetchingTravellersAroundMe(){
        self.fetchTravellersAroundMeTimer = Timer.scheduledTimer(timeInterval: AppConstants.ServerConnectivity.fetchUsersAroundMeFrequency,
                                                                 target: self,
                                                                 selector: #selector(fetchTravellersAroundMe),
                                                                 userInfo: nil,
                                                                 repeats: true)
    }
    
    func stopFetchingTravellersAroundMe(){
        self.fetchTravellersAroundMeTimer.invalidate()
    }
    
    
    @objc private func fetchTravellersAroundMe(){
        if(self.isAllowedToConnect){
            ServerAPIManager.sharedInstance.fetchTravellersAroundMe{
                result in
                guard result.error == nil else {
                    self.handleFetchTravellersTravellersAroundMeError(result.error!)
                    return
                }
                if let fetchedTravellers = result.value {
                    DispatchQueue.main.async {      //Avoid Race Conditions
                        self.travellers = fetchedTravellers
                    }
                }
            }
        }
    }
    
    private func handleFetchTravellersTravellersAroundMeError(_ error: Error) {
        //TODO: Show Error
        debugPrint("handleLoadTravellersError: LoadTravellers Error")
    }


    
//MARK: Update User Location
    func updateLocation(location: Location){
        if(self.isAllowedToConnect){
            serialQueue.async{
                ServerAPIManager.sharedInstance.updateLocation(location: location){
                    result in
                    guard result.error == nil else {
                        self.handleUpdateLocationError(result.error!)
                        return
                    }
                    debugPrint("DataHolder: updateLocation successful")
                    // If it is the first time The update Locatino is Called
                    // Then Fire the Timer for Fetching the users around us
                    if (!self.fetchTravellersAroundMeTimer.isValid){
                        self.startFetchingTravellersAroundMe()
                    }
                }
            }
        }
    }
    
    func handleUpdateLocationError(_ error: Error) {
        //TODO: Show Error
        debugPrint("HandleUpdateLocationError: updateLocation error")
    }
    
    
//MARK: Stop All Connectivity
    func stopAllConnections(){
        self.isAllowedToConnect = false
    }
    
    func startAllConnections(){
        self.isAllowedToConnect = true
        stopFetchingTravellersAroundMe() // stop the timer
    }
    
}
