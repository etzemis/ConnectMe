//
//  Destination.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 12/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import MapKit

class Location: NSObject {
    var address: String?
    var region: String?
    var coord: CLLocationCoordinate2D
    
    
    init (coord:CLLocationCoordinate2D){
        self.address = nil
        self.region = nil
        self.coord = coord
    }
    init(address: String?, region:String?, coord:CLLocationCoordinate2D) {
        self.address = address
        self.region = region
        self.coord = coord
    }
    
    func printObject() -> String
    {
        return  "Address: \(self.address ?? "empty"), \n" +
                "Region: \(self.region ?? "empty")\n" +
                "Coordinates: { Latitude: \(self.coord.latitude), Longitude: \(self.coord.longitude) )\n"
    }
}
