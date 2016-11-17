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
    static let sharedInstance = TripDataHolder()

    var isAllowedToConnect = true // Flag to stop all connections
    
    var listenForInvitationsTimer = Timer()
    var RefreshStatusTimer = Timer()
    var travellersInInvitation: [Traveller] = [] {
        didSet{
//            //Will be called from Main Thread so it is safe
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.InvitationToTripReceived), object: self)
        }
    }
    
    
//    STATUS =
//    {
//      0: HAVE NOT YET RESPONDED
//      1: REJECTED
//      2: ACCEPTED
//      3: Cancelled
//    }
    var TravellersInInvitationStatus: [String: Int] = [:]
    
    
    
    //*************************************************************
    //MARK: Listen for Invitations
    //*************************************************************

    
    func startListeningForInvitations(){
        self.listenForInvitationsTimer = Timer.scheduledTimer(timeInterval: AppConstants.ServerConnectivity.listenForInvitationsFrequency,
                                                                 target: self,
                                                                 selector: #selector(listenForInvitations),
                                                                 userInfo: nil,
                                                                 repeats: true)
        
    }
    
    func stopListeningForInvitations(){
        self.listenForInvitationsTimer.invalidate()
    }
    
    
    @objc private func listenForInvitations(){
        if(self.isAllowedToConnect){
            ServerAPIManager.sharedInstance.refreshInvitations{
                result in
                guard result.error == nil else {
                    self.handleListenForInvitationsError(result.error!)
                    return
                }
                if let travellersInInvitation = result.value {
                    DispatchQueue.main.async {      //Avoid Race Conditions
                        self.travellersInInvitation = travellersInInvitation
                    }
                }
            }
        }
    }
    
    private func handleListenForInvitationsError(_ error: Error) {
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        case ServerAPIManagerError.network:
            debugPrint("Network problem")
        case ServerAPIManagerError.objectSerialization:
            debugPrint("Problem in Serialization")
        case ServerAPIManagerError.apiProvidedError:
            debugPrint("No Invitations")
        default:
            debugPrint("handleListenForInvitationsError -->  UNKNOWN Error")
        }
        
        debugPrint("handleListenForInvitationsError!!!!")
    }
    
    
    

    
    
    
    //*************************************************************
    //MARK: Trip Request Status Update
    //*************************************************************
    
    
    func startRefreshingStatus(){
        self.RefreshStatusTimer = Timer.scheduledTimer(timeInterval: AppConstants.ServerConnectivity.TripRequestRefreshStatusFrequency,
                                                              target: self,
                                                              selector: #selector(refreshStatus),
                                                              userInfo: nil,
                                                              repeats: true)
        
    }
    
    func stopRefreshingStatus(){
        self.listenForInvitationsTimer.invalidate()
    }
    
    
    @objc private func refreshStatus(){
        if(self.isAllowedToConnect){
            ServerAPIManager.sharedInstance.refreshInvitations{
                result in
                guard result.error == nil else {
                    self.handleListenForInvitationsError(result.error!)
                    return
                }
                // handle Response
                self.updateTripStatus()
                self.updateTravellersInInvitationStatus()
            }
        }
    }
    
    private func handleRefreshStatusError(_ error: Error) {
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        case ServerAPIManagerError.network:
            debugPrint("Network problem")
        case ServerAPIManagerError.objectSerialization:
            debugPrint("Problem in Serialization")
        case ServerAPIManagerError.apiProvidedError:
            debugPrint("No News!")
        default:
            debugPrint("handle Refresh Status Error -->  UNKNOWN Error")
        }
        
        debugPrint("handle Refresh Status Error!!!!")
    }
    
    
    func updateTripStatus(){
    
    }
    
    func updateTravellersInInvitationStatus(){
        
    }
    
    

    
    
    //*************************************************************
    //MARK: Handle All Connectivity
    //*************************************************************

    func stopAllConnections(){
        self.isAllowedToConnect = false
    }
    
    func startAllConnections(){
        self.isAllowedToConnect = true
    }
    
    private func handleLostAuthorisation(){
        DataHolder.sharedInstance.handleLostAuthorisation()
    }
    
    
    

}
