//
//  Destination.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 12/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import MapKit

class Destination: NSObject {
    var address: String
    var region: String
    var coord: CLLocationCoordinate2D
    
    init(address: String, region:String, coord:CLLocationCoordinate2D) {
        self.address = address
        self.region = region
        self.coord = coord
    }
}
