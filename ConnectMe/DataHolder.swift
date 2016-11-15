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
//MARK: Update it Accordingly
    
    var userLoggedIn = Traveller()
    
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
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        default:  // network
            return
        }
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
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
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
                        self.fetchTravellersAroundMe() // Cal it instantly and then it will start every 10s
                        self.startFetchingTravellersAroundMe()
                    }
                }
            }
        }
    }
    
    func handleUpdateLocationError(_ error: Error) {
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        default:  // network
            return
        }
        debugPrint("HandleUpdateLocationError: updateLocation error")
    }
    
//MARK: LOST AUTHORISATION
    public func handleLostAuthorisation(){
        //find the View in which we are in
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
        
            //present Alert
            let alert = UIAlertController(title: "Lost Authorization", message: "You will be redirected on the login screen to start all over again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in
                //log out USER
                UserDefaults.standard.set(false, forKey: AppConstants.HandleUserLogIn.IsUserLoggedInUserDefaults)
                DataHolder.sharedInstance.stopAllConnections()
                UserDefaults.standard.synchronize()
            
                //show LoginViewController
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else {
                    assert(false, "Misnamed view controller")
                    return
                }
                topController.present(loginVC, animated: true, completion: nil)
            }
            alert.addAction(okAction)
            topController.present(alert, animated: true, completion: nil)

        }
            return
    }
    
//MARK: Stop All Connectivity
    func stopAllConnections(){
        self.isAllowedToConnect = false
    }
    
    func startAllConnections(){
        self.isAllowedToConnect = true
        stopFetchingTravellersAroundMe() // stop the timer
    }
    
//MARL: Helper Functions
    func urlToDownload(image: String) -> String {
        return AppConstants.ServerConnectivity.baseUrlString+image
    }
    
}
