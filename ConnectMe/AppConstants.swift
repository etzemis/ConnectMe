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
        //Trip
        static let TravellersAroundMeTripUpdated = "TravellersAroundMeTripUpdatedNotification"
    }
    
    struct HandleUserLogIn{
        static let UsernameUserDefaults = "emailUser"
        static let PasswordTokenUserDefaults = "passwordTokenUser"
        static let nicknameUserDefaults = "nicknameUser"
        static let imageUrlUserDefaults = "imageUrlUser"
        static let IsUserLoggedInUserDefaults = "IsUserLoggedIn"
    }
    
    struct ServerConnectivity{
        static let baseUrlString = "http://192.168.1.113:3000/"
        static let fetchUsersAroundMeFrequency = 10.0  // Time Interval for Calling the Server FetchUsersAroundMe Function
        static let serialqueue = "ConnectMeServerSerialQueue"
    }
    
    static let UserLocationAccuracyinMeters = 10.0  // My location will not be updated if my location changes less than those meters
}
