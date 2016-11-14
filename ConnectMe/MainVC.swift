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
import PINRemoteImage


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
    

    
    // MARK: Variables
    private var isInitialized = false;
    var userLastUpdatedLocation = CLLocation() //The last Location that has been send to the server
    private var locationManager: CLLocationManager = CLLocationManager()
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!{didSet {setUpMap()}}

    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBAction func mapTypeChanged(_ sender: Any) {
        switch (self.mapTypeSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = .standard;
            self.mapTypeSegmentedControl.tintColor = self.view.tintColor
            break;
        case 1:
            self.mapView.mapType = .hybrid;
            self.mapTypeSegmentedControl.tintColor = UIColor.white
            break;
        default:
            break;
        }
    }
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe (listen for) "special notification key"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTravellersUpdatedNotification),
                                               name: NSNotification.Name(AppConstants.NotificationNames.TravellersAroundMeUpdated), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.TravellersAroundMeUpdated), object: nil);
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: AppConstants.HandleUserLogIn.IsUserLoggedInUserDefaults)

        if !isUserLoggedIn{
            self.isInitialized = false //stop connections will be called form logging out
            performSegue(withIdentifier: Constants.UserLoginSegue, sender: self)
        }
        else if !self.isInitialized{
            //set it to false when Logging out!
            self.isInitialized = !self.isInitialized
            
            setUpLocationManager()
            displayUsers(users: createBotUsers())
            
            //Fetch User from User Defaults
            let defaults  = UserDefaults.standard
            DataHolder.sharedInstance.userLoggedIn.name = defaults.string(forKey: AppConstants.HandleUserLogIn.nicknameUserDefaults)!
            DataHolder.sharedInstance.userLoggedIn.imageUrl = defaults.string(forKey: AppConstants.HandleUserLogIn.imageUrlUserDefaults)!
        }
    }

    
    
// MARK: Act On Notifications
    @objc private func actOnTravellersUpdatedNotification(){
        print("Received Notification")
        displayUsers(users: DataHolder.sharedInstance.travellers)
        
    }

    
// MARK: Initialization Location Manager and Map
    func setUpLocationManager(){
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func setUpMap(){
        mapView.mapType = .standard
        mapView.showsPointsOfInterest = true
        mapView.showsScale = true
        mapView.showsBuildings = true
        mapView.showsCompass = true
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
        if let annotation = view.annotation as? Traveller {
            if let thumbnailImageView = view.leftCalloutAccessoryView as? UIImageView{
                
                thumbnailImageView.clipsToBounds = true
                thumbnailImageView.contentMode = .scaleAspectFill
//                thumbnailImageView.image = #imageLiteral(resourceName: "empty_profile")
                
//                if let urlString = annotation.imageUrl{
//                    ServerAPIManager.sharedInstance.imageFrom(urlString: urlString)
//                    {
//                        (image, error) in
//                        guard error == nil else{
//                            print (error!)
//                            return
//                        }
//                        thumbnailImageView.image = image                        
//                    }
//                }
                
                let urlString = annotation.imageUrl
                let url = URL(string: urlString)
                thumbnailImageView.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "empty_profile")) { _ in return}
//                } else {
//                    thumbnailImageView.image = #imageLiteral(resourceName: "empty_profile")
//                }

                
//                if let urlString = annotation.imageUrl,
//                   let url = URL(string: urlString) {
//                    thumbnailImageView.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "empty_profile")) { _ in return}
//                } else {
//                    thumbnailImageView.image = #imageLiteral(resourceName: "empty_profile")
//                }
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
        
        let user = Traveller(name: "Vaggelis",
                        destination: Location(address: "Kolokotroni 33-41", region: "Egaleo", coord: CLLocationCoordinate2D(latitude: 37.997272, longitude: 23.686664)),
                        currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))
        users.append(user)
        return users
    }
    
    
    
    
    /// Change it and check if annotation is Selected.. if yes then postpone it until it is deselected
    ///
    /// - Parameter users: the travellers we will be displaying as Annotations in the MapView
    func displayUsers(users:[Traveller]){
        let annotations = mapView.annotations
        for an in mapView.selectedAnnotations{
            mapView.deselectAnnotation(an, animated: true)
        }
        mapView.removeAnnotations(annotations)
        mapView.addAnnotations(users)
    }

}


//MARK: Location Delegate Methods
extension MainVC{

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            let distance = self.userLastUpdatedLocation.distance(from: location) as Double
            debugPrint("Distance from Previous Location \(distance)")
            if distance > AppConstants.UserLocationAccuracyinMeters{
                self.userLastUpdatedLocation = location
                DataHolder.sharedInstance.updateLocation(location: Location(address: nil, region: nil, coord: location.coordinate))
                let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.01, 0.01) )
                mapView.setRegion(region, animated: true)
            }
            
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError){ print("Error \(error)") }
    
}






