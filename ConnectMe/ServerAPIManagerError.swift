//
//  ServerAPIManagerError.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 02/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation

enum ServerAPIManagerError: Error {
    //A generic networking error that wraps up another error.When Alamofire gives us an error
    case network(error: Error)  // if 500
    
    //The API gave us an error in the JSON that it returned
    case apiProvidedError(reason: String)  // if "message"
    

    //Credentials are not valid anymore
    case authLost(reason: String)  // // Authorization Error

    
    //Can not get the data we want out of the JSON
    case objectSerialization(reason: String)  // if can not parse JSON
}

