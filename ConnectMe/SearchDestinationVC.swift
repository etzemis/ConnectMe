//
//  SearchDestinationVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 17/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftSpinner

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class SearchDestinationVC: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    struct Constants{
        static let ConfirmDestinationSegue = "Show Travellers"
        static let SpanAroundUserRegion = MKCoordinateSpanMake(0.2, 0.2)
    }
    //MARK: Variable Declaration
    @IBOutlet weak var mapView: MKMapView!{ didSet { setUpMap() }}
    @IBOutlet weak var NextButton: UIBarButtonItem!
    @IBAction func BarButtonPressed(_ sender: AnyObject) {
        
        if searchController!.isActive {
            searchController?.isActive = false
        }
        else{
            SwiftSpinner.show("Syncing Destination...")
            let delayInSeconds = 3.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                SwiftSpinner.hide()
                self.performSegue(withIdentifier: Constants.ConfirmDestinationSegue, sender: sender)
            }
        }
    }
    @IBOutlet weak var extraPersonsLabel: UILabel!
    private var extraPersons = 0
    @IBAction func increaseExtraPersons(_ sender: Any) {
        if(extraPersons < 20){
            self.extraPersons = extraPersons+1
            self.extraPersonsLabel.text = "\(self.extraPersons)"
        }
    }
    @IBAction func decreaseExtraPersons(_ sender: Any) {
        if(extraPersons > 0){
            self.extraPersons = extraPersons-1
            self.extraPersonsLabel.text = "\(self.extraPersons)"
        }
    }
    
    var userSelectedDestination = false
    var locationManager: CLLocationManager = CLLocationManager()
    
    //Search Bar
    var searchController: UISearchController? = nil
    var selectedPin:MKPlacemark? = nil


    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpSearchController()
        setUpLocationManager()
    }

    // MARK: Search Controller Initialization
    private func setUpSearchController(){
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        searchController = CustomSearchController(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = searchController!.searchBar
        searchBar.delegate = self
        searchBar.isTranslucent = true
        searchBar.barStyle = .blackTranslucent
        searchBar.sizeToFit()
        searchBar.placeholder = "Enter destination"
        navigationItem.titleView = searchController?.searchBar
 
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true

        //By default, the modal overlay will take up the entire screen, covering the search bar.
        //definesPresentationContext limits the overlap area to just the View Controller’s frame instead of the whole Navigation Controller.
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem?.title = " Cancel"
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem?.title = "Next"
        self.navigationItem.rightBarButtonItem?.isEnabled = userSelectedDestination
    }

    

    // MARK: Map & LocationManager Initialization
    private func setUpMap(){
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.delegate = self
        //region intialized base on current location
    }
    
    func setUpLocationManager(){
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    //MARK: MapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        else{
            let reuseId = "pin"
            var view: MKPinAnnotationView? = nil
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier:reuseId)as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                view!.canShowCallout = true
                view!.calloutOffset = CGPoint(x: -5, y: 5)
                view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            }
            return view
        }
        
    }
    
    // MARK: Perform Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ConfirmDestinationSegue{

                if segue.destination is TravellersTVC {
                    
                    //set the user to display the Info
                    //SET Users Destination
                    //Call load Suggestions
                    //Set the back button to have no title
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                }
            }
    }
}



//MARK: HandleMapSearch Methods
extension SearchDestinationVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        //Enable Next Button and Set Flag
        NextButton.isEnabled = true
        self.userSelectedDestination = true
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}


//MARK: Location Delegate Methods
extension SearchDestinationVC {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
            let region = MKCoordinateRegion(center: location.coordinate, span: Constants.SpanAroundUserRegion)
            mapView.setRegion(region, animated: false)
            
        }
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
        
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error \(error)")
    }
    

}

