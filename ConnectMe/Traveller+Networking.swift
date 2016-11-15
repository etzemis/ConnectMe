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
    
    convenience init?(json: [String: Any], proximity: Int = -1) {
        for (key, value) in json {
            print("\(key) - \(value) - \(type(of:value) )")
        }
        
        guard
            let email = json["email"] as? String,
            let name = json["username"] as? String,
            let imageUrl = json["imageUrl"] as? String,
            let location = json["location"] as? [Any],
            let destination = json["destination"] as? [String:Any] else
        {
                return nil
        }
        
        guard let currentLongitude = location[0] as? Double,
            let currentLatitude = location[1] as? Double else
        {
                return nil
        }

            
        guard   let destAddress = destination["address"] as? String,
                let destRegion = destination["region"] as? String,
                let extraPersons = destination["extraPersons"] as? Int,
                let destLocation = destination["coordinates"] as? [Any] else
        {
                return nil
        }
        
        guard let destLongitude = destLocation[0] as? Double,
            let destLatitude = destLocation[1] as? Double else{
                return nil
        }
        
        print (destination)
        
        // Since it is optional, unwrap it later
//        let porximity = json["proximity"] as? String


        let userDestination = Location(address: destAddress,
                                   region: destRegion,
                                   coord: CLLocationCoordinate2D(latitude: destLatitude, longitude: destLongitude))
        // Use existing initializer
        self.init(email: email,
                  name: name,
                  destination: userDestination,
                  proximity: proximity,
                  extraPersons: extraPersons,
                  currentCoord: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude),
                  imageUrl:imageUrl)
    }
    

}
