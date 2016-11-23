//
//  MeetingPointAnnotation.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 21/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import MapKit

class MeetingPointAnnotation: NSObject, MKAnnotation {
    
    var coord: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coord = coordinate
    }
    

    var coordinate: CLLocationCoordinate2D{
        return coord
    }
    var title: String? {
        return "MeetingPoint"
    }
    var subtitle: String?{
        return nil
    }

}
