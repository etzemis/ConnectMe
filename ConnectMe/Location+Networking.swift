//
//  ToDo+Networking.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

extension Location{
    convenience init?(json: [String: Any]) {
        guard let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double
            else {
                return nil
            }
        // Since it is optional, unwrap it later
        let address = json["address"] as? String
        let region = json["region"] as? String
        
        
        // Use existing initializer
        self.init(address: address,
                  region: region,
                  coord: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
    func toJSON() -> [String: Any] {
        var json = [String: Any]()
        
        json["latitude"]  = self.coord.latitude
        json["longitude"] = self.coord.longitude
        // It is optional
        if let addr = self.address {
            json["address"] = addr
        }
        if let reg = self.region {
            json["region"] = reg
        }
        return json
    }
    


}
