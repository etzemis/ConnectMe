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

    //*************************************************************
    //MARK: Variable Declaration
    //*************************************************************

    struct Constants{
        static let ConfirmDestinationSegue = "Show Travellers"
        static let SpanAroundUserRegion = MKCoordinateSpanMake(0.2, 0.2)
    }
    @IBOutlet weak var mapView: MKMapView!{ didSet { setUpMap() }}
    @IBOutlet weak var NextButton: UIBarButtonItem!
    
    var userDestination = MKPointAnnotation()

    //*************************************************************
    //MARK: ExtraPersons Management
    //*************************************************************

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

    
    //*************************************************************
    //MARK: Insert Destination Remote
    //*************************************************************

    @IBAction func insertDestinationBarButtonPressed(_ sender: AnyObject) {
        
        if searchController!.isActive {
            searchController?.isActive = false  //Dismiss the Search Controller
        }
        else{
            Spinner.sharedInstance.show(uiView: (self.navigationController?.view)!)
            
            let destination  = Location(address: userDestination.title, region: userDestination.subtitle, coord: userDestination.coordinate)
            DataHolder.sharedInstance.insertDestination(destination: destination, extraPersons: self.extraPersons)
            
        }
    }
    
    
    //*************************************************************
    //MARK: ViewController Lifecycle
    //*************************************************************

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnDestinationUpdatedSuccessfuly),
                                               name: NSNotification.Name(AppConstants.NotificationNames.DestinationUpdatedSuccessfuly), object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnDestinationFailedToUpdate),
                                               name: NSNotification.Name(AppConstants.NotificationNames.DestinationFailedToUpdate), object: nil)

        //
        setUpSearchController()
        setUpLocationManager()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.DestinationUpdatedSuccessfuly), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(AppConstants.NotificationNames.DestinationFailedToUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
        
    }
    
    
    @objc private func actOnDestinationUpdatedSuccessfuly(){
        DispatchQueue.main.async {
            Spinner.sharedInstance.hide(uiView: (self.navigationController?.view)!)
            //Up-date the userLoggedInInstance!!!
            DataHolder.sharedInstance.userLoggedIn.destination = Location(address: self.userDestination.title,
                                                                          region: self.userDestination.subtitle,
                                                                          coord: self.userDestination.coordinate)
            DataHolder.sharedInstance.userLoggedIn.extraPersons = self.extraPersons
            //Perform Segue
            self.performSegue(withIdentifier: Constants.ConfirmDestinationSegue, sender: self.NextButton)
        }
    }
    
    @objc private func actOnDestinationFailedToUpdate(){
        //present ALert
        let alertController = UIAlertController(title: "Could not establish Connection", message: "Please check your internet connection and  try again" ,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            Spinner.sharedInstance.hide(uiView: (self.navigationController?.view)!)
            self.present(alertController, animated: true, completion: nil)
        }

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
                    
                    //Stop Fetching Users
                    
                    DataHolder.sharedInstance.stopFetchingTravellersAroundMe() //!!!!!!!!
                    
                    //set Toolbar
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
        self.userDestination = MKPointAnnotation()
        self.userDestination.coordinate = placemark.coordinate
        self.userDestination.title = parseAddress(selectedItem: placemark)
        self.userDestination.subtitle = parseRegion(selectedItem: placemark)
        mapView.addAnnotation(self.userDestination)
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


extension SearchDestinationVC{
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? ""
        )
        return addressLine
    }
    func parseRegion(selectedItem:MKPlacemark) -> String {
        
        if selectedItem.locality == selectedItem.administrativeArea{
            return selectedItem.locality!
        }
        // put a space between "Washington" and "DC"
        let region = String(
            format:"%@%@%@",
            // city
            selectedItem.locality ?? "",
            " ",
            // state
            selectedItem.administrativeArea ?? ""
        )
        return region
    }


}

