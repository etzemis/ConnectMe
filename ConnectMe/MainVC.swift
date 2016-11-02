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
import SwiftSpinner

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: Constants
    private struct Constants{
        static let FullTrackColor = UIColor.blue //Add alpha component to 0.5
        static let TrackLineWidth: CGFloat = 3.0
        static let LeftCalloutFrame = CGRect(x:0, y:0, width:50, height:50)
        static let AnnotationViewReuseIdentifier = "traveller point"
        static let UserLocationReuseIdentifier = "user location"
        static let ShowUserSegue = "Show User"
        static let SelectDestinationSegue = "Select Destination"
        static let CreateTripSegue = "Create Trip"
        static let UserLoginSegue = "UserLogin"
        static let RegionRadius: CLLocationDistance = 250
        static let PinSelectedColor: UIColor = UIColor.blue
        static let PinNormalColor: UIColor = UIColor.brown
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Variables
    private var CreateTripModeIsOn: Bool = false
    private var locationManager: CLLocationManager = CLLocationManager()
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        displayUsers(users: createBotUsers())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: AppDelegate.Constants.IsUserLoggedInUserDefaults){
            performSegue(withIdentifier: Constants.UserLoginSegue, sender: self)
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
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.delegate = self
        //set User Location dot to be of Different Color
        mapView.tintColor = UIColor.lightGray
    }
    
    // MARK: Perform Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ShowUserSegue{
            if let user = (sender as? MKAnnotationView)?.annotation as? Traveller{
                if let userdetVC = segue.destination as? UserDetailsVC {
                    //set the user to display the Info
                    userdetVC.user = user
                    //Set the back button to have no title
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                }
            }
        }
        else if segue.identifier == Constants.SelectDestinationSegue{
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
            print("Seque to Destination")
        }
    }
    
    // MARK: MKMapView Delegate
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        
        if let annotation = annotation as? Traveller {
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier:Constants.AnnotationViewReuseIdentifier){ // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
                view.image = #imageLiteral(resourceName: "travellerPinLowProximity")
                view.canShowCallout = true
                //set Right Callout Accessory View
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
                //set Left Callout Accessory View
                view.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let _ = view.annotation as? Traveller {
            if let thumbnailImageView = view.leftCalloutAccessoryView as? UIImageView{
                
                thumbnailImageView.clipsToBounds = true
                thumbnailImageView.contentMode = .scaleAspectFill
                thumbnailImageView.image = #imageLiteral(resourceName: "empty_profile")
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Check if this is what we want exactly
        //if yes then segue
        performSegue(withIdentifier: Constants.ShowUserSegue, sender: view)
    }
    
    // MARK: Bot Users
    func createBotUsers() -> [Traveller]{
        var users = [Traveller]()
        
        var user = Traveller(travellerId: 1, name: "Vaggelis",
                        destination: Location(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
        users.append(user)
        
        user = Traveller(travellerId: 2, name: "Petros",
                    destination: Location(address: "Ermou 83-85", region: "Athens", coord: CLLocationCoordinate2D(latitude: 37.976648, longitude: 23.726223)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.984470, longitude: 23.680367))
        users.append(user)
        
        user = Traveller(travellerId: 3 , name: "Hercules",
                    destination: Location(address: "Andromachis 237", region: "Pireas", coord: CLLocationCoordinate2D(latitude: 37.941077, longitude: 23.670781)),
                    currentCoord: CLLocationCoordinate2D(latitude: 37.985240, longitude: 23.680818))
        users.append(user)
        
        return users
    }
    
    
    func displayUsers(users:[Traveller]){
        mapView.addAnnotations(users)
    }

}


//MARK: Location Delegate Methods
extension MainVC{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.01, 0.01) )
            mapView.setRegion(region, animated: true)
//            let delayInSeconds = 4.0
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
//                            SwiftSpinner.show("Getting Nearby Travellers...")
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2*delayInSeconds) {
//                SwiftSpinner.hide()
//            }
            

            
        }
        // let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
}






