//
//  TripDataHolder.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 19/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import UIKit

/// Holds All the connectiosn for the App While not in a Trip
class TripDataHolder{
    //MARK: Class variables
    static let sharedInstance = TripDataHolder()
    
    var isAllowedToConnect = true // Flag to stop all connections
    var RefreshStatusTimer = Timer()
    var fetchMyTravellersTimer = Timer()
    
    
    
    var travellers: [Traveller] = [] {
        didSet{
            //Wiil be called from Main Thread so it is safe
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.MyTravellersUpdated), object: self)
        }
        
    }
    
    
    //*************************************************************
    //MARK: Fetch My Travellers
    //*************************************************************

    func startFetchingMyTravellers(){
        self.fetchMyTravellersTimer = Timer.scheduledTimer(timeInterval: AppConstants.ServerConnectivity.fetchMyTravellersFrequency,
                                                                 target: self,
                                                                 selector: #selector(fetchMyTravellers),
                                                                 userInfo: nil,
                                                                 repeats: true)
        
    }
    
    func stopFetchingMyTravellers(){
        self.fetchMyTravellersTimer.invalidate()
    }
    
    
    @objc private func fetchMyTravellers(){
        if(self.isAllowedToConnect){
            ServerAPIManager.sharedInstance.fetchTravellersAroundMe{
                result in
                guard result.error == nil else {
                    self.handleFetchMyTravellersError(result.error!)
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
    
    
    private func handleFetchMyTravellersError(_ error: Error) {
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
            debugPrint("handleFetchMyTravellersError -->  UNKNOWN Error")
        }
        
        debugPrint("handleFetchMyTravellersErrors: LoadTravellers Error")
    }
    
    
    private func handleLostAuthorisation(){
        DataHolder.sharedInstance.handleLostAuthorisation()
    }
    

}
