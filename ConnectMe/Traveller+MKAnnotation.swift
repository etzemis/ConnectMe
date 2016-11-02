//
//  MKUser.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 12/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import MapKit

extension Traveller: MKAnnotation{
    var coordinate: CLLocationCoordinate2D{
        return currentCoord
    }
    var title: String? {
        return name
    }
    var subtitle: String?{
        return destination.region
    }
    
}
