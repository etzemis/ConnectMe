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
    }
    
    struct HandleUserLogIn{
        static let UsernameUserDefaults = "username"
        static let PasswordTokenUserDefaults = "passwordToken"
        static let IsUserLoggedInUserDefaults = "IsUserLoggedIn"
    }
    
    struct ServerConnectivity{
        static let fetchUsersAroundMeFrequency = 10.0  // Time Interval for Calling the Server FetchUsersAroundMe Function
        static let serialqueue = "ConnectMeServerSerialQueue"
    }
}
