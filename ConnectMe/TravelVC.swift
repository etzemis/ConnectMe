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

    //*************************************************************
    //MARK: Constants
    //*************************************************************

    struct Constants{
        static let FullTrackColor = UIColor.blue.withAlphaComponent(0.5) //Add alpha component to 0.5
        static let TrackLineWidth: CGFloat = 5.0
        static let RegionRadius: CLLocationDistance = 250
        static let PinSelectedColor: UIColor = UIColor.blue
        static let PinNormalColor: UIColor = UIColor.brown
        static let AnnotationViewReuseIdentifier = "coTraveller point"
        static let LeftCalloutFrame = CGRect(x:0, y:0, width:50, height:50)
        static let MinimumDistanceFromMeetingPoint = 50.0  // in meters
        static let MinimumDistanceFromDestination = 100.0  // in meters
    }
    
    //*************************************************************
    //MARK: Variables
    //*************************************************************

    var locationManager: CLLocationManager = CLLocationManager()
    var myCurrentLocation = CLLocation()
    var meetingPoint = CLLocation()
    
    
    var isApproachingMeetingPoint = true
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}
    
    
    
    //*************************************************************
    //MARK: View Controller Lifecycle
    //*************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        // show The Toolbar
        self.navigationController?.isToolbarHidden = true

        
        self.navigationItem.title = "Walk towards the Meeting Point"
        
        
        setUpLocationManager()
        // Do any additional setup after loading the view.
        // Observe (listen for) "special notification key"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnMyTravellersUpdatedNotification),
                                               name: NSNotification.Name(AppConstants.NotificationNames.MyTravellersUpdated), object: nil)
        
        
        
        Spinner.sharedInstance.show(uiView: (self.navigationController?.view)!)
        getTripMeetingPoint()
        TripDataHolder.sharedInstance.startFetchingMyTravellers()
        
        
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.MyTravellersUpdated), object: nil);
    }
    
    
    
    
    //*************************************************************
    //MARK: Act on traveller position changed
    //*************************************************************

    @objc private func actOnMyTravellersUpdatedNotification()
    {
        displayUsers(users: TripDataHolder.sharedInstance.travellers)
    }

    
    func displayUsers(users:[Traveller]){
        var annotations = mapView.annotations
        var i = 0
        for an in annotations{
            mapView.deselectAnnotation(an, animated: true)
            if an is MeetingPointAnnotation
            {
                annotations.remove(at: i)
            }
            i += 1
        }
        mapView.removeAnnotations(annotations)
        mapView.addAnnotations(users)
    }
    
    
    
    //*************************************************************
    //MARK: Get Trip Meeting Point
    //*************************************************************



    private func getTripMeetingPoint()
    {
        ServerAPIManager.sharedInstance.fetchTripMeetingPoint {
            result in
            guard result.error == nil else {
                self.handleGetTripMeetingPointError(result.error!)
                return
            }
            
            //send success Notification
            DispatchQueue.main.async {
                Spinner.sharedInstance.hide(uiView: (self.navigationController?.view)!)
                self.meetingPoint = CLLocation(latitude: result.value!.latitude, longitude: result.value!.longitude)
                self.showDirectionsToMeetingPoint()
            }

        }
    }
    //TODO: Handle "Message" Error
    func handleGetTripMeetingPointError(_ error: Error) {
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        default:  // network
            return
        }
        debugPrint("handleGetTripMeetingPointError: updateLocation error")
    }
    
    
    //*************************************************************
    //MARK: Show Directions To Meeting Point
    //*************************************************************

    func showDirectionsToMeetingPoint() {
        
        //Check if meeting point is Too close!
        
        let distance = myCurrentLocation.distance(from: meetingPoint) as Double
        
        if distance > Constants.MinimumDistanceFromMeetingPoint {
            
            // 1. Create Placemarks
            let startPlacemark = MKPlacemark(coordinate: myCurrentLocation.coordinate, addressDictionary: nil)
            let finishPlacemark = MKPlacemark(coordinate: meetingPoint.coordinate, addressDictionary: nil)
            
            // 2. Create MapItems, used for Routing
            let startMapItem = MKMapItem(placemark: startPlacemark)
            let finishMapItem = MKMapItem(placemark: finishPlacemark)
            
            // 3. Create Meeting Point annotation in the map
            let finishAnnotation = MeetingPointAnnotation(coordinate: meetingPoint.coordinate)
            
            
            // 4.
            self.mapView.addAnnotation(finishAnnotation)
            
            // 5.
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = startMapItem
            directionRequest.destination = finishMapItem
            directionRequest.transportType = .walking
            
            // 6. Calculate the directions
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
        else{
            
            let finishAnnotation = MeetingPointAnnotation(coordinate: meetingPoint.coordinate)
            self.mapView.addAnnotation(finishAnnotation)
            
            // Zoom close to the user
            let region = MKCoordinateRegion(center: myCurrentLocation.coordinate, span: MKCoordinateSpanMake(0.002, 0.002) )
            self.mapView.setRegion(region, animated: false)
        }
    }
    
    
    
    //*************************************************************
    //MARK: Set up Map & LocationManager
    //*************************************************************


    func setUpLocationManager(){
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func setUpMap(){
        mapView.mapType = .standard
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
    }
    
    
    //*************************************************************
    //MARK: MapView Delegate
    //*************************************************************
    //TODO: Make it work both for Traveller but also for normal pin!
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if annotation is Traveller {
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier:Constants.AnnotationViewReuseIdentifier){ // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
                view.image = #imageLiteral(resourceName: "travellerPinLowProximity")
                view.canShowCallout = true
                //set Left Callout Accessory View
                view.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
                
            }
            return view
        }
        else if annotation is MeetingPointAnnotation{
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier:"Meeting Point annotation"){ // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
                
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: "Meeting Point annotation")
                view.image = #imageLiteral(resourceName: "meetingPoint")
                view.canShowCallout = true
                view.centerOffset = CGPoint(x: 0, y: -view.frame.height/2)
                
            }
            return view

        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? Traveller
        {
            if let thumbnailImageView = view.leftCalloutAccessoryView as? UIImageView
            {
                
                thumbnailImageView.clipsToBounds = true
                thumbnailImageView.contentMode = .scaleAspectFill
                
                
                let urlString = annotation.imageUrl
                let url = URL(string: urlString)
                thumbnailImageView.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "empty_profile")) { _ in return}
                
            }
        }

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = Constants.FullTrackColor
        renderer.lineWidth = Constants.TrackLineWidth
        return renderer
    }
    
    
    private func handleLostAuthorisation()
    {
        DataHolder.sharedInstance.handleLostAuthorisation()
    }
    
    
    //*************************************************************
    //MARK: Arrived At Meeting Point
    //*************************************************************
    func actOnArrivedAtMeetingPoint()
    {
        //remove overlay
        let overlays  = mapView.overlays
        mapView.removeOverlays(overlays)
        //remove Meeting point annotation
        let annotations = mapView.annotations
        for an in annotations{
            if an is MeetingPointAnnotation
            {
                mapView.removeAnnotation(an)
            }
        }
    }
    
    //*************************************************************
    //MARK: Arrived At Destination
    //*************************************************************
    
    func actOnArrivedAtDestination()
    {
        TripDataHolder.sharedInstance.stopAllConnections()
        
        //show alert
        let alert = UIAlertController(title: "You have arrived at Your Destination", message: "Thank you for using USave. See you soon!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        //Inform the Server that I have arrived at my Destination
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}


//*************************************************************
//MARK: Location Delegate
//*************************************************************

extension TravelVC{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
            let distance = self.myCurrentLocation.distance(from: location) as Double
            
            if distance > AppConstants.UserLocationAccuracyinMeters{
                self.myCurrentLocation = location
                if( isApproachingMeetingPoint )
                {
                    if (self.myCurrentLocation.distance(from: self.meetingPoint) < Constants.MinimumDistanceFromMeetingPoint)
                    {
                        self.isApproachingMeetingPoint = false
                        self.actOnArrivedAtMeetingPoint()
                    }
                }
                else
                {
                    let destinationCoord = DataHolder.sharedInstance.userLoggedIn.destination.coord
                    let destination = CLLocation(latitude: destinationCoord.latitude, longitude: destinationCoord.longitude)
                    
                    if (self.myCurrentLocation.distance(from: destination ) < Constants.MinimumDistanceFromDestination)
                    {
                        self.actOnArrivedAtDestination()
                    }
                }
                
            }
        }
        
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
    
}


