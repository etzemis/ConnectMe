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

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class SearchDestinationVC: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var DismissButton: UIBarButtonItem!
    //MARK: Variable Declaration
    @IBOutlet weak var mapView: MKMapView!{ didSet { setUpMap() }}
    //Location
    var locationManager: CLLocationManager = CLLocationManager()
    let span = MKCoordinateSpanMake(0.2, 0.2)
    //Search Bar
    var searchController: UISearchController? = nil
    var selectedPin:MKPlacemark? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpLocationManager()
        setUpSearchController()
    }
    
    @IBAction func DismissController(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
        searchBar.placeholder = "Enter your desired destination"
        navigationItem.titleView = searchController?.searchBar
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true

        //By default, the modal overlay will take up the entire screen, covering the search bar.
        //definesPresentationContext limits the overlap area to just the View Controller’s frame instead of the whole Navigation Controller.
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem?.title = " Cancel"
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem?.title = "Dismiss"
    }

    

    // MARK: Map, Location Manager Initialization
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
}



//MARK: HandleMapSearch Methods
extension SearchDestinationVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
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
            
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
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

