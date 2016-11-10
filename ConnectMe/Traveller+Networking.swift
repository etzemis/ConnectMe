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
        guard let name = json["username"] as? String,
            let address = json["address"] as? String,
            let region = json["region"] as? String,
            let currentLatitude = json["currentLatitude"] as? Double,
            let currentLongitude = json["currentLongitude"] as? Double,
            let destinationLatitude = json["destinationLatitude"] as? Double,
            let destinationLongitude = json["destinationLongitude"] as? Double,
            let extraPersons = json["extraPersons"] as? Int,
            let imageUrl = json["imageUrl"] as? String
            else {
                return nil
        }
        // Since it is optional, unwrap it later
//        let porximity = json["proximity"] as? String



        let userDestination = Location(address: address,
                                   region: region,
                                   coord: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude))
        // Use existing initializer
        self.init(name: name,
                   destination: userDestination,
                   extraPersons: extraPersons,
                   currentCoord: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude),
                   imageUrl:imageUrl)
    }
    

}
