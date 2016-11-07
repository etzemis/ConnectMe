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
    }
    
    struct HandleUserLogIn{
        static let UsernameUserDefaults = "username"
        static let PasswordTokenUserDefaults = "passwordToken"
        static let IsUserLoggedInUserDefaults = "IsUserLoggedIn"
        static let HasApplicationStartedWithLoggedInUserUserDefaults = "AppStartedwithLoggedInuser"  // Used to handle the situation when user logs out while using the App!
    }
}
