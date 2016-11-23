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

    private struct Constants{
        static let FullTrackColor = UIColor.blue.withAlphaComponent(0.5) //Add alpha component to 0.5
        static let TrackLineWidth: CGFloat = 5.0
        static let RegionRadius: CLLocationDistance = 250
        static let PinSelectedColor: UIColor = UIColor.blue
        static let PinNormalColor: UIColor = UIColor.brown
        static let AnnotationViewReuseIdentifier = "coTraveller point"
        static let LeftCalloutFrame = CGRect(x:0, y:0, width:50, height:50)
    }
    
    //*************************************************************
    //MARK: Variables
    //*************************************************************

    var locationManager: CLLocationManager = CLLocationManager()
    var myCurrentLocation = CLLocationCoordinate2D()
    private var meetingPoint = CLLocationCoordinate2D()
    
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}
    
    
    
    //*************************************************************
    //MARK: View Controller Lifecycle
    //*************************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        // show The Toolbar
        self.navigationController?.isToolbarHidden = true

        setUpLocationManager()
        // Do any additional setup after loading the view.
        // Observe (listen for) "special notification key"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnMyTravellersUpdatedNotification),
                                               name: NSNotification.Name(AppConstants.NotificationNames.TravellersAroundMeUpdated), object: nil)
        
        
        
        Spinner.sharedInstance.show(uiView: (self.navigationController?.view)!)
        getTripMeetingPoint()
        
        
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.TravellersAroundMeUpdated), object: nil);
    }
    
    
    
    
    //*************************************************************
    //MARK: Act on traveller position changed
    //*************************************************************

    @objc private func actOnMyTravellersUpdatedNotification()
    {
        displayUsers(users: TripDataHolder.sharedInstance.travellers)
    }

    
    func displayUsers(users:[Traveller]){
        let annotations = mapView.annotations
        for an in mapView.selectedAnnotations{
            mapView.deselectAnnotation(an, animated: true)
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
                self.meetingPoint = result.value!
                self.showDirectionsToMeetingPoint()
            }

        }
    }
    
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

        // 1. Create Placemarks
        let startPlacemark = MKPlacemark(coordinate: myCurrentLocation, addressDictionary: nil)
        let finishPlacemark = MKPlacemark(coordinate: meetingPoint, addressDictionary: nil)
        
        // 2. Create MapItems, used for Routing
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let finishMapItem = MKMapItem(placemark: finishPlacemark)
        
        // 3. Create Meeting Point annotation in the map
        let finishAnnotation = MeetingPointAnnotation(coordinate: meetingPoint)
        
        
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
            
//            let rect = route.polyline.boundingMapRect
//            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
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
    
    
    func createBotUsers() -> [Traveller]{
        var users = [Traveller]()
        
        var user = Traveller(email: "",
                         name: "Vaggelis",
                         destination: Location(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                         proximity: 1,
                         extraPersons: 1,
                         currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877),
                         imageUrl:"vvagdancer@gmail.jpg")
    
        users.append(user)
        
        user = Traveller(email: "",
                         name: "Alexis",
                         destination: Location(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                         proximity: 1,
                         extraPersons: 1,
                         currentCoord: CLLocationCoordinate2D(latitude: 37.984420, longitude: 23.681888),
                         imageUrl:"vvagdancer@gmail.jpg")
        
        users.append(user)
        
        self.meetingPoint = CLLocationCoordinate2D(latitude: 37.988982, longitude: 23.689453)

        
        return users
    }

    
}


//*************************************************************
//MARK: Location Delegate
//*************************************************************

extension TravelVC{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            self.myCurrentLocation = location.coordinate
            
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.015, 0.015) )
            mapView.setRegion(region, animated: false)
            
        }
        
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
    
}


