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
    
    // MARK: Variables
    private var CreateTripModeIsOn: Bool = false
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}
    // MARK: Constants
    private struct Constants{
        static let FullTrackColor = UIColor.blue //Add alpha component to 0.5
        static let TrackLineWidth: CGFloat = 3.0
        static let AnnotationViewReuseIdentifier = "user point"
        static let ShowUserSegue = "Show User"
        static let SelectDestinationSegue = "Select Destination"
        static let RegionRadius: CLLocationDistance = 1000
    }
    
    @IBAction func createTrip(_ sender: AnyObject) {
        if !CreateTripModeIsOn {
            if sender is UIBarButtonItem{
                self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(createTrip(_:))), animated: true)
                self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(createTrip(_:))), animated: true)
                self.navigationItem.title = "Select Users"
                //navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 200, green: 200, blue: 200, alpha: 1.0)
                //navigationController?.navigationBar.tintColor = UIColor.white
                
            }
        }
        else{
            if let button = sender as? UIBarButtonItem{
                //check if Invite or Cancel
                if button.title == "Cancel" {
                    self.navigationItem.setRightBarButton(
                        UIBarButtonItem(title: "Create Trip", style: .plain, target: self, action: #selector(createTrip(_:))), animated: true)
                    self.navigationItem.setLeftBarButton(
                        UIBarButtonItem(title: "Destination", style: .plain, target: self, action: #selector(selectDestination(_:))), animated: true)
                    self.navigationItem.title = "Connect Me"
                }
                else if button.title == "Invite" {
                    
                }
            }
        }
        CreateTripModeIsOn = !CreateTripModeIsOn
    }
    
    func selectDestination(_ sender: AnyObject) {
        performSegue(withIdentifier: Constants.SelectDestinationSegue, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        displayUsers(users: createBotUsers())
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
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    // MARK: Perform Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ShowUserSegue{
            if let user = (sender as? MKAnnotationView)?.annotation as? User{
                if let userdetVC = segue.destination as? UserDetailsVC {
                    //set the user to display the Info
                    userdetVC.user = user
                    //Set the back button to have no title
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                }
            }
        }
        else if segue.identifier == Constants.SelectDestinationSegue{ print("Seque to Destination")}
    }
    
    // MARK: MKMapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if let annotation = annotation as? User {
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier:Constants.AnnotationViewReuseIdentifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Check if this is what we want exactly
        //if yes then segue
        performSegue(withIdentifier: Constants.ShowUserSegue, sender: view)
    }
    
    // MARK: Bot Users
    func createBotUsers() -> [User]{
        var users = [User]()
        
        var user = User(id: 1 as NSNumber, name: "Vaggelis",
                        destination: Destination(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
        users.append(user)
        
        user = User(id: 2 as NSNumber, name: "Petros",
                    destination: Destination(address: "Ermou 83-85", region: "Athens", coord: CLLocationCoordinate2D(latitude: 37.976648, longitude: 23.726223)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367))
        users.append(user)
        
        user = User(id: 3 as NSNumber, name: "Hercules",
                    destination: Destination(address: "Andromachis 237", region: "Pireas", coord: CLLocationCoordinate2D(latitude: 37.941077, longitude: 23.670781)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.985240, longitude: 23.680818))
        users.append(user)
        
        return users
    }
    
    func displayUsers(users:[User]){
        mapView.addAnnotations(users)
        //mapView.showAnnotations(users, animated: true)
    }

}


//MARK: Location Delegate Methods
extension MainVC{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.02, 0.02) )
            mapView.setRegion(region, animated: true)
            
        }
        // let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
}






