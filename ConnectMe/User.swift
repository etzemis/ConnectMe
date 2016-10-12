//
//  User.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 10/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import MapKit

class User: NSObject {
    var id: NSNumber
    var name: String
    var destination: Destination
    var currentCoord: CLLocationCoordinate2D
    
    init(id: NSNumber, name: String, destination: Destination, currentCoord: CLLocationCoordinate2D){
        self.id = id
        self.name = name
        self.destination = destination
        self.currentCoord = currentCoord
    }
}
