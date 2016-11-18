//
//  TravelVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 25/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TravelVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    // MARK: Constants
    private struct Constants{
        static let FullTrackColor = UIColor.blue.withAlphaComponent(0.5) //Add alpha component to 0.5
        static let TrackLineWidth: CGFloat = 3.0
        static let RegionRadius: CLLocationDistance = 250
        static let PinSelectedColor: UIColor = UIColor.blue
        static let PinNormalColor: UIColor = UIColor.brown
                static let AnnotationViewReuseIdentifier = "traveller point"
    }
    
     // MARK: Variables
    private var locationManager: CLLocationManager = CLLocationManager()

    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
       // setUpLocationManager()
        setUpOverlay()

        // Do any additional setup after loading the view.
    }
    
    
    func setUpOverlay() {
        // 2. Create Trip Locations
        let sourceLocation = CLLocationCoordinate2D(latitude: 37.984904, longitude: 23.681382)
        let destinationLocation = CLLocationCoordinate2D(latitude: 37.991051, longitude: 23.682154)
        
        // 3. Create Placemarks
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 4. Create MapItems, used for Routing
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 5. Create annotations in the map
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Home"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Metro Egaleo"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 6.
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8. Get the directions
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    // MARK: Initialization Location Manager and Map
    func setUpLocationManager(){
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func setUpMap(){
        mapView.mapType = .standard
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
    }
    
    
    // MARK: MKMapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if let annotation = annotation as? Traveller {
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier:Constants.AnnotationViewReuseIdentifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
                view.canShowCallout = true
                view.pinTintColor = Constants.PinNormalColor
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            }
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = Constants.FullTrackColor
        renderer.lineWidth = Constants.TrackLineWidth
        return renderer
    }

    
}


//MARK: Location Delegate Methods
extension TravelVC{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
                let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.015, 0.015) )
                mapView.setRegion(region, animated: true)
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
    
}


