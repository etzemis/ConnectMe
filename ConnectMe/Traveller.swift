//
//  User.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 10/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import MapKit

class Traveller: NSObject {
    var id: Int
    var name: String
    var destination: Location
    var extraPersons: Int
    var currentCoord: CLLocationCoordinate2D
    
    init(travellerId id: Int, name: String, destination: Location, extraPersons: Int = 0, currentCoord: CLLocationCoordinate2D){
        self.id = id
        self.name = name
        self.destination = destination
        self.extraPersons = extraPersons
        self.currentCoord = currentCoord
    }
}
