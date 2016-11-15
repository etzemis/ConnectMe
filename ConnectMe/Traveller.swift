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
    var email: String
    var name: String
    var destination: Location
    var extraPersons: Int
    var currentCoord: CLLocationCoordinate2D
    private var _imageUrl: String = "default"
    var imageUrl: String {
        set{
            _imageUrl = newValue
        }
        get{
            return DataHolder.sharedInstance.urlToDownload(image: _imageUrl)
        }
    }
    
    
    override init(){
        self.email = ""
        self.name = ""
        self.destination = Location(address: nil, region: nil, coord: CLLocationCoordinate2D())
        self.extraPersons = 0
        self.currentCoord = CLLocationCoordinate2D()
    }
    init(email: String, name: String, destination: Location, extraPersons: Int = 0, currentCoord: CLLocationCoordinate2D, imageUrl: String = "default"){
        self.email = email
        self.name = name
        self.destination = destination
        self.extraPersons = extraPersons
        self.currentCoord = currentCoord
        self._imageUrl = imageUrl
    }
}
