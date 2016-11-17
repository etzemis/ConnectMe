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
    var travellersInInvitation: [Traveller] = [] {
        didSet{
//            //Wiil be called from Main Thread so it is safe
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.InvitationToTripReceived), object: self)
        }
    }
    
    
    
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
            break
        case ServerAPIManagerError.objectSerialization:
            break
        case ServerAPIManagerError.apiProvidedError:
            break
        default:
            debugPrint("handleListenForInvitationsError -->  UNKNOWN Error")
        }
        
        debugPrint("handleListenForInvitationsError!!!!")
    }
    
    
    
    private func handleLostAuthorisation(){
        DataHolder.sharedInstance.handleLostAuthorisation()
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

}
