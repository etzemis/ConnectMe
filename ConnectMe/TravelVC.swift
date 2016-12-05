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
        static let MinimumDistanceFromMeetingPoint = 15.0  // in meters
        static let MinimumDistanceFromDestination = 15.0  // in meters
    }
    
    //*************************************************************
    //MARK: Variables
    //*************************************************************
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}
    var locationManager: CLLocationManager = CLLocationManager()
    
    
    
    //Store the meeting Point and the Current Location!
    var myCurrentLocation = CLLocation()
    var meetingPoint = CLLocation()
    var myDestination = CLLocation()
    
    var hasApproachedMeetingPoint = false
    var hasApproachedDestination = false

    
    
    
    //*************************************************************
    //MARK: View Controller Lifecycle
    //*************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        // show The Toolbar
        self.navigationController?.isToolbarHidden = true
        self.navigationItem.title = "Walk towards the Meeting Point"
        
        
        
        // calculate Location of Destination
        let destinationCoord = DataHolder.sharedInstance.userLoggedIn.destination.coord
        myDestination = CLLocation(latitude: destinationCoord.latitude, longitude: destinationCoord.longitude)
        
        
        setUpLocationManager()
        
        // Listen for Notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnMyTravellersUpdatedNotification),
                                               name: NSNotification.Name(AppConstants.NotificationNames.MyTravellersUpdated), object: nil)
        
        Spinner.sharedInstance.show(uiView: self.view)
        
        
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
        displayTravellers(users: TripDataHolder.sharedInstance.travellers)
    }

    
    func displayTravellers(users:[Traveller]){
        let annotations = mapView.annotations
        var travellerAnnotations = [Traveller] ()
        for an in annotations{
            if (an is Traveller)
            {
                travellerAnnotations.append(an as! Traveller)
            }
        }
        mapView.removeAnnotations(travellerAnnotations)
        mapView.addAnnotations(users)
    }
    
    
    func displayDestination()
    {
        // cretae Destination Annotation
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = DataHolder.sharedInstance.userLoggedIn.destination.coord
        destinationAnnotation.title = "Your Destination"
        destinationAnnotation.subtitle = DataHolder.sharedInstance.userLoggedIn.destination.address!
        
        // Display it
        self.mapView.addAnnotation(destinationAnnotation)
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
                self.meetingPoint = CLLocation(latitude: result.value!.latitude, longitude: result.value!.longitude)
                // Diplay Our destination
                self.displayDestination()
                //Show Directions
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
        
        
        // If am not at the meeting point -> Show Route
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
            
            // 7. Get the directions
            directions.calculate {
                (response, error) -> Void in
                
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    
                    return
                }
                
                
                //Hide The Spinner 
                Spinner.sharedInstance.hide(uiView: self.view)
                
                let route = response.routes[0]
                self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        }
            
        // If I am at the meeting point
        else{
            //showAlert
            showArrivalAtMeetingPoint(title: "You already are at the Meeting Point")
            
            //Hide The Spinner
            Spinner.sharedInstance.hide(uiView: self.view)
            
            // HAs Approached Meeting Point
            self.hasApproachedMeetingPoint = true
            self.navigationItem.title = "Tracking your route..."
            
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
        showArrivalAtMeetingPoint(title: "You have arrived at the Meeting Point")
        
        self.navigationItem.title = "Tracking your route..."
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
    
    func showArrivalAtMeetingPoint(title: String)
    {
        //show alert
        let alert = UIAlertController(title: title, message: "Please gather together with the rest of the Travellers and get into a taxi :-). We will take care of the rest.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        //Inform the Server that I have arrived at my Destination
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //*************************************************************
    //MARK: Arrived At Destination
    //*************************************************************
    
    func actOnArrivedAtDestination()
    {
        //Notify the Server
        sendArrivedAtTripDestination()
        
        self.navigationItem.title = "Arrived at Destination"
        TripDataHolder.sharedInstance.stopAllConnections()
        
        //show alert
        let alert = UIAlertController(title: "You have arrived at Your Destination", message: "Thank you for using USave. See you soon!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func sendArrivedAtTripDestination() {
        ServerAPIManager.sharedInstance.arrivedAtTripDestination
            {
                result in
                guard result.error == nil else {
                    self.handleArrivedAtTripDestinationError(result.error!)
                    return
                }
        }
    }
    
    
    func handleArrivedAtTripDestinationError(_ error: Error) {
        switch error {
        case ServerAPIManagerError.authLost:
            handleLostAuthorisation()
        default:  // network
            return
        }
        debugPrint("handleArrivedAtTripDestinationError")
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
                
                // if I have arrived at the Meeting Point
                if( !hasApproachedMeetingPoint && self.myCurrentLocation.distance(from: self.meetingPoint) < Constants.MinimumDistanceFromMeetingPoint)
                {
                        self.hasApproachedMeetingPoint = true
                        self.actOnArrivedAtMeetingPoint()
                }
                else if (!hasApproachedDestination)
                {
                    if (self.myCurrentLocation.distance(from: self.myDestination ) < Constants.MinimumDistanceFromDestination)
                    {
                        hasApproachedDestination = true
                        self.actOnArrivedAtDestination()
                    }
                }
                
            }
        }
        
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
    
}


