//
//  Contants.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 07/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation

struct AppConstants{
    struct NotificationNames{
        static let TravellersAroundMeUpdated = "TravellersAroundMeUpdatedNotification"
        static let DestinationUpdatedSuccessfuly = "DestinationUpdatedSuccessfulyNotification"
        static let DestinationFailedToUpdate = "DestinationFailedToUpdateNotification"
        //TripRequest
        static let InvitationToTripReceived = "InvitationToTripReceivedNotification"
        static let TripRequestTripStatusChanged = "TripRequestTripStatusChangedNotification"
        static let TripRequestTravellerStatusChanged = "TripRequestTravellerStatusChangedNotification"
        //Trip
        static let MyTravellersUpdated = "MyTravellersUpdatedNotification"
    }
    
    struct HandleUserLogIn{
        static let UsernameUserDefaults = "emailUser"
        static let PasswordTokenUserDefaults = "passwordTokenUser"
        static let nicknameUserDefaults = "nicknameUser"
        static let imageUrlUserDefaults = "imageUrlUser"
        static let IsUserLoggedInUserDefaults = "IsUserLoggedIn"
    }
    
    struct ServerConnectivity{
        static let baseUrlString = "http://connectmeserver-92909.onmodulus.net/" //"http://192.168.1.172:3000/"
        // "http://connectmeserver-92909.onmodulus.net/"
        
        static let fetchUsersAroundMeFrequency = 10.0  // Time Interval for Calling the Server FetchUsersAroundMe Function
        static let fetchMyTravellersFrequency = 3.0  // Time Interval for Calling the Server fetchMyTravellers Function
        static let listenForInvitationsFrequency = 1.0  // Time Interval for updating Invitation Requests
        static let TripRequestRefreshStatusFrequency = 5.0  // Time Interval for Refreshing Status
        static let serialqueue = "ConnectMeServerSerialQueue"
    }
    
    struct HandleTripRequest{
        static let InvitationAutoRejectTime = 300.0
    }
    
    static let UserLocationAccuracyinMeters = 10.0  // My location will not be updated if my location changes less than those meters
}
