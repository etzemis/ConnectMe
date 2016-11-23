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
class TripRequestDataHolder{
    //MARK: Class variables
    static let sharedInstance = TripRequestDataHolder()

    var isAllowedToConnect = true // Flag to stop all connections
    var listenForInvitationsTimer = Timer()
    var RefreshStatusTimer = Timer()
    
    
    
    
    var travellersInInvitation: [Traveller] = [] {
        didSet{
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.InvitationToTripReceived), object: self)
        }
    }
    
    
    
    
    //*************************************************************
    //MARK: Travaller & Trip Status
    //*************************************************************

    
    enum travellerStatusEnum: Int {
        case waiting, accepted, rejected, cancelled
    }
    
    enum tripStatusEnum: Int {
        case waiting, started, cancelled
    }
    
    var travellerStatus: travellerStatusEnum = .waiting
    var tripStatus: tripStatusEnum = .waiting
    
    
    var travellersInInvitationStatus: [String: travellerStatusEnum] = [:]
    
    
    
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
        refreshStatus()
        self.RefreshStatusTimer = Timer.scheduledTimer(timeInterval: AppConstants.ServerConnectivity.TripRequestRefreshStatusFrequency,
                                                              target: self,
                                                              selector: #selector(refreshStatus),
                                                              userInfo: nil,
                                                              repeats: true)
        
    }
    
    func stopRefreshingStatus(){
        self.RefreshStatusTimer.invalidate()
    }
    
    
    @objc private func refreshStatus(){
        if(self.isAllowedToConnect){
            ServerAPIManager.sharedInstance.refreshStatusTripRequest{
                result in
                guard result.error == nil else {
                    self.handleRefreshStatusError(result.error!)
                    return
                }
                // handle Response
                
                if let (tripStatus, travellerStatus) = result.value {
                    self.updateTripStatus(tripStatus: tripStatus)
                    self.updateTravellersInInvitationStatus(travellerStatus: travellerStatus)
                }
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
    
    
    func updateTripStatus(tripStatus: Int){
        self.tripStatus = tripStatusEnum(rawValue: tripStatus)!
        
        //post Notification!!
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.TripRequestTripStatusChanged), object: self)
        }
    }
    
    func updateTravellersInInvitationStatus(travellerStatus: [String: Int]){
        print("\n\n\n Before\n\n \(travellersInInvitationStatus)")
        for (email, _) in travellerStatus
        {
            travellersInInvitationStatus[email] = travellerStatusEnum(rawValue: travellerStatus[email]!)
        }
        
        print("\n\n\n After \n \(travellersInInvitationStatus)")
        
        //post Notification!
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(AppConstants.NotificationNames.TripRequestTravellerStatusChanged), object: self)
        }
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
