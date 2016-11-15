//
//  Traveller+Networking.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 02/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import CoreLocation

extension Traveller{
    
    convenience init?(json: [String: Any]) {
        for (key, value) in json {
            print("\(key) - \(value) - \(type(of:value) )")
        }
        
        guard
            let email = json["email"] as? String,
            let name = json["username"] as? String,
            let imageUrl = json["imageUrl"] as? String,
            let location = json["location"] as? [Any]
        else {
                return nil
        }
        
        guard let currentLongitude = location[0] as? Double,
            let currentLatitude = location[1] as? Double else{
                return nil
        }

//        guard let destination = json["destination"] as? [Any],
//            let address = destination
        
        // Since it is optional, unwrap it later
//        let porximity = json["proximity"] as? String


        let userDestination = Location(address: "Test",
                                   region: "Test",
                                   coord: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        // Use existing initializer
        self.init(email: email,
                  name: name,
                  destination: userDestination,
                  extraPersons: 1,
                  currentCoord: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude),
                  imageUrl:imageUrl)
    }
    

}
