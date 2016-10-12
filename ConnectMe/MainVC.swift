//
//  ViewController.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 08/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            setUpMap()
        }
    }
    var locationManager: CLLocationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 500
    
    // MARK: Constants
    private struct Constants{
        static let FullTrackColor = UIColor.blue //Add alpha component to 0.5
        static let TrackLineWidth: CGFloat = 3.0
        static let AnnotationViewReuseIdentifier = "user point"
        static let ShowUserSegue = "ShowUser"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        displayUsers(users: createBotUsers())
    }
    
    // MARK: Bot Users
    func createBotUsers() -> [User]{
        var users = [User]()
        

        var user = User(id: 1 as NSNumber, name: "User 1",
                        destination: Destination(address: "TestAdress 1", region: "TestRegion 1", coord: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
            users.append(user)
        
        user = User(id: 2 as NSNumber, name: "User 2",
            destination: Destination(address: "TestAdress 2", region: "TestRegion 2", coord: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
            currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367))
        users.append(user)
        
        user = User(id: 3 as NSNumber, name: "User 3",
            destination: Destination(address: "TestAdress 3", region: "TestRegion 3", coord: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
            currentCoord: CLLocationCoordinate2D(latitude: 37.985240, longitude: 23.680818))
        users.append(user)
        
        return users
    }
    
    func displayUsers(users:[User]){
        mapView.addAnnotations(users)
        mapView.showAnnotations(users, animated: true)
    }

    // MARK: Location MAnager Initialization
    
    func setUpLocationManager(){
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: Map Initialization
    func setUpMap(){
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.delegate = self
        let initialLocation = CLLocation(latitude: 37.984803, longitude: 23.681393)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // MARK: MK Annotation 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
        }
        else{
            view!.annotation = annotation
        }
        
        if let user = annotation as? User{
            //check 1:01:01
        }
        return view
    }
    
    
    
    //MARK: Location Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error \(error)")
    }
}

