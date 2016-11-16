//
//  ServerAPIManager.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import Alamofire

class ServerAPIManager {
    static let sharedInstance = ServerAPIManager()
    
    
    
    //*************************************************************
    //MARK: Helepr Functions
    //*************************************************************

    func checkUnauthorized(urlResponse: HTTPURLResponse) -> (Error?) {
        if (urlResponse.statusCode == 401) {
            return ServerAPIManagerError.authLost(reason: "Not Logged In")
        }
        return nil
    }
    
    //Fetch Images
    func imageFrom(urlString: String,
                   completionHandler: @escaping (UIImage?, Error?) -> Void) {
        let _ = Alamofire.request(urlString)
            
            .response { dataResponse in
                // use the generic response serializer that returns Data
                guard let data = dataResponse.data else {
                    completionHandler(nil, dataResponse.error)
                    return
                }
                let image = UIImage(data: data)
                completionHandler(image, nil) }
    }

    
    /// Alamofire uses the default URLCache to cache the URL responses so we need to flush out the cache before refreshing. 
    /// Otherwise we’ll just get the cached response and won’t see any new gists. 
    /// To implement clearing the cache we can use removeAllCachedResponses() on the shared URL cache.
    func clearCache() -> Void {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
    
    
  
    
    
    
    

    
    //*************************************************************
    //MARK: Registration
    //*************************************************************


    func register(username: String,
                  email: String,
                  password: String,
                  profileImage: UIImage?,
                  address: String,
                  completionHandler: @escaping (Result<Bool>) -> Void)
    {
        
        var imageAsData = "default"
        //Compress the image
        if let image = profileImage {
            if let imageData = image.jpegData(.lowest) {
                imageAsData = imageData.base64EncodedString()
                let test = NSData(base64Encoded: imageAsData, options: .ignoreUnknownCharacters)
                if let _ = test?.isEqual(to: imageData) {
                    print ("\n\n\n\ntrue\n\n\n")
                }
                print(imageAsData)
                print(imageData.count)
                
            }
        }
        
        
        //First Create JSON Object that you will be sending to the Server
        let parameters: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "address": address,
            "profilePhoto": imageAsData
        ]
        
        let request = Alamofire.request(ConnectMeRouter.register(parameters))
            .responseJSON { response in
                guard response.result.error == nil else {
                    print(response.result.error!)
                    return completionHandler(.failure(ServerAPIManagerError.network(error: response.result.error!)))
                }
                
                // check for "message" errors in the JSON because this API does that
                if  let jsonDictionary = response.result.value as? [String: Any],
                    let errorMessage = jsonDictionary["message"] as? String
                {
                    return completionHandler(.failure(ServerAPIManagerError.apiProvidedError(reason: errorMessage)))
                }
                
                //Otherwise Success
                completionHandler(.success(true))
        }
        print("\n\n\n\n  Registration request \n\n\n\n")
        debugPrint(request)
    }
    
    
    
    //*************************************************************
    //MARK: User Login
    //*************************************************************

    
    func login(email: String,
               password: String,
               completionHandler: @escaping (Result<[String:String]>) -> Void)
    {
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let request = Alamofire.request(ConnectMeRouter.login(parameters))
            .responseJSON { response in
                let result = self.tokenFromResponse(response:response)
                completionHandler(result)
        }
        print("\n\n\n\n  Login request \n\n\n\n")
        debugPrint(request)
    }
    
    
    //Parses the response and gets the Token we need for the Basic Authorization
    //Also Parse name and imageURL
    private func tokenFromResponse(response: DataResponse<Any>) -> Result<[String: String]>
    {

        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(ServerAPIManagerError.network(error: response.result.error!))
        }
        
        // make sure we got JSON and it's a single value
        guard let jsonKey = response.result.value as? [String: Any] else {
            print("\n Didn't get The Token as JSON from API")
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        // check for "message" errors in the JSON because this API does that
        if  let jsonDictionary = response.result.value as? [String: Any],
            let errorMessage = jsonDictionary["message"] as? String
        {
            return .failure(ServerAPIManagerError.apiProvidedError(reason: errorMessage))
        }
        
        guard   let token = jsonKey["token"] as? String,
                let username = jsonKey["username"] as? String,
                let imageUrl = jsonKey["imageUrl"] as? String else{
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        let res = ["token": token,
                   "username": username,
                   "imageUrl": imageUrl]
        return .success(res)
    }


    //*************************************************************
    //MARK: Activate
    //*************************************************************

    func activate(completionHandler: @escaping (Result<Bool>) -> Void)
    {
        let request = Alamofire.request(ConnectMeRouter.activate())
            .response { response in
                
                //Error Handling
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in update Location \n")
                    completionHandler(.failure(authError))
                    return
                }
                guard response.error == nil else {
                    print(response.error!)
                    completionHandler(.failure(ServerAPIManagerError.network(error: response.error!)))
                    return
                }
                
                //Otherwise Success
                completionHandler(.success(true))
        }
        print("\n\n\n\n  Activate Request \n\n\n\n")
        debugPrint(request)
        
    }
    
   
    //*************************************************************
    //MARK: Deactivate
    //*************************************************************
    
    func deactivate(completionHandler: @escaping (Result<Bool>) -> Void)
    {
        let request = Alamofire.request(ConnectMeRouter.deactivate())
            .response { response in
                
                //Error Handling
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in update Location \n")
                    completionHandler(.failure(authError))
                    return
                }
                guard response.error == nil else {
                    print(response.error!)
                    completionHandler(.failure(ServerAPIManagerError.network(error: response.error!)))
                    return
                }
                
                //Otherwise Success
                completionHandler(.success(true))
        }
        print("\n\n\n\n  Deactivate Request \n\n\n\n")
        debugPrint(request)
        
    }
    

    //*************************************************************
    //MARK: Update Location
    //*************************************************************


    func updateLocation(location: Location,
                        completionHandler: @escaping (Result<Bool>) -> Void)
    {
        //First Create JSON Object that you will be sending to the Server
        let parameters: [String: Any] = location.toJSON()
        
        let request = Alamofire.request(ConnectMeRouter.updateLocation(parameters))
            .response { response in
                
                //Error Handling
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in update Location \n")
                    completionHandler(.failure(authError))
                    return
                }
                guard response.error == nil else {
                    print(response.error!)
                    completionHandler(.failure(ServerAPIManagerError.network(error: response.error!)))
                    return
                }
                
                //Otherwise Success
                completionHandler(.success(true))
        }
        print("\n\n\n\n  Update Location Request \n\n\n\n")
        debugPrint(request)
    }

                        
    
    //*************************************************************
    //MARK: Fetch Travellers Around Me
    //*************************************************************


    func fetchTravellersAroundMe(completionHandler: @escaping (Result<[Traveller]>) -> Void)
    {
       let request = Alamofire.request(ConnectMeRouter.fetchTravellersAroundMe())
            .responseJSON { response in
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in FetchTravellersAroundMe \n")
                    completionHandler(.failure(authError))
                    return
                }
                print(response)
                let result = self.travellerArrayFromResponse(response:response)
                completionHandler(result)
        }
        
        print("\n\n\n\n  FetchTravellersAroundMe request \n\n\n\n")
        debugPrint(request)
    }

    // Parse Responce
    private func travellerArrayFromResponse(response: DataResponse<Any>) -> Result<[Traveller]>
    {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(ServerAPIManagerError.network(error: response.result.error!))
        }

        // check for "message" errors in the JSON because this API does that
        if  let jsonDictionary = response.result.value as? [String: Any],
            let errorMessage = jsonDictionary["message"] as? String
        {
            return .failure(ServerAPIManagerError.apiProvidedError(reason: errorMessage))
        }
        
        // make sure we got JSON Array
        guard let jsonArray = response.result.value as? [[String: Any]] else {
            print("Didn't get array of Travellers as JSON from API")
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }

        
        
        let travellers = jsonArray.flatMap{ Traveller(json: $0) }
        return .success(travellers)
    }
    

    
    //*************************************************************
    //MARK: Insert Destination
    //*************************************************************


    func insertDestination(destination: Location, extraPersons: Int, completionHandler: @escaping (Result<Bool>) -> Void)
    {
        
        //First Create JSON Object that you will be sending to the Server
        var parameters: [String: Any] = destination.toJSON()
        parameters["extraPersons"] = extraPersons  // add the extraPersons Parameter
        
        let request = Alamofire.request(ConnectMeRouter.insertDestination(parameters))
            .response { response in
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n Authorization Error in Insert Destination \n")
                    completionHandler(.failure(authError))
                    return
                }
                
                guard response.error == nil else {
                    print(response.error!)
                    completionHandler(.failure(ServerAPIManagerError.network(error: response.error!)))
                    return
                }
                
                //Otherwise Success
                completionHandler(.success(true))
        }
        
        print("\n\n\n\n  Insert Destination request \n\n\n\n")
        debugPrint(request)
    }
    
    
    
    
//*************************************************************
//MARK: Trip Request
//*************************************************************
    
    
    
    //*************************************************************
    //MARK: Fetch Travellers Around Me TRIP Request
    //*************************************************************
    
    
    func fetchTravellersAroundMeTrip(completionHandler: @escaping (Result<[Traveller]>) -> Void)
    {
        let request = Alamofire.request(ConnectMeRouter.fetchTravellersAroundMeTrip())
            .responseJSON { response in
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in FetchTravellersAroundMe \n")
                    completionHandler(.failure(authError))
                    return
                }
                print(response)
                let result = self.tripTravellerArrayFromResponse(response:response)
                completionHandler(result)
        }
        
        print("\n\n\n\n  FetchTravellersAroundMe Trip request \n\n\n\n")
        debugPrint(request)
    }
    
    // Parse Responce
    private func tripTravellerArrayFromResponse(response: DataResponse<Any>) -> Result<[Traveller]>
    {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(ServerAPIManagerError.network(error: response.result.error!))
        }
        
        // check for "message" errors in the JSON because this API does that
        if  let jsonDictionary = response.result.value as? [String: Any],
            let errorMessage = jsonDictionary["message"] as? String
        {
            return .failure(ServerAPIManagerError.apiProvidedError(reason: errorMessage))
        }
        
        // make sure we got JSON Array
        guard let jsonArray = response.result.value as? [String:Any] else {
            print("Didn't get array of Travellers as JSON from API")
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        guard let highproxJson = jsonArray["0"] as? [[String: Any]],
            let medproxJson = jsonArray["1"] as? [[String: Any]],
            let lowproxJson = jsonArray["2"] as? [[String: Any]] else {
                return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        var travellers = [Traveller]()

        let highProxTravellers = highproxJson.flatMap{ Traveller(json: $0, proximity: 0) }
        let medProxTravellers = medproxJson.flatMap{ Traveller(json: $0, proximity: 1) }
        let lowProxTravellers = lowproxJson.flatMap{ Traveller(json: $0, proximity:2) }
        
        travellers = highProxTravellers+medProxTravellers+lowProxTravellers
        
        return .success(travellers)
    }
    
    
    //*************************************************************
    //MARK: Create Trip Request
    //*************************************************************
    func createTripRequest(travellers: [String], completionHandler: @escaping (Result<[String]>) -> Void)
    {
        let parameters: [String: Any] = [
            "travellers": travellers
        ]

        let request = Alamofire.request(ConnectMeRouter.createTripRequest(parameters))
            .responseJSON { response in
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in createTripRequest \n")
                    completionHandler(.failure(authError))
                    return
                }
                print(response)
                let result = self.createTripRequestHandleResponse(response: response)
                completionHandler(result)
        }
        
        print("\n\n\n\n  Create Trip Request \n\n\n\n")
        debugPrint(request)
    }
    
    private func createTripRequestHandleResponse(response: DataResponse<Any>) -> Result<[String]>
    {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(ServerAPIManagerError.network(error: response.result.error!))
        }
        
        // check for "message" errors in the JSON because this API does that
        if  let jsonDictionary = response.result.value as? [String: Any],
            let errorMessage = jsonDictionary["message"] as? String
        {
            return .failure(ServerAPIManagerError.apiProvidedError(reason: errorMessage))
        }
        
        // make sure we got JSON Array
        guard let jsonArray = response.result.value as? [String:Any] else {
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        
        guard let travellers = jsonArray["success"] as? [String] else {
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get an array with The users invited to the Trip Request"))
        }
        
        return .success(travellers)
    }
    
    //*************************************************************
    //MARK: Refresh Trip Request
    //*************************************************************
    func refreshTripRequest(completionHandler: @escaping (Result<[Traveller]>) -> Void)
    {
        let request = Alamofire.request(ConnectMeRouter.refreshTripRequest())
            .responseJSON { response in
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in createTripRequest \n")
                    completionHandler(.failure(authError))
                    return
                }
                print(response)
                let result = self.refreshTripRequestHandleResponse(response: response)
                completionHandler(result)
        }
        
        print("\n\n\n\n  Create Trip Request \n\n\n\n")
        debugPrint(request)

    }
    
    private func refreshTripRequestHandleResponse(response: DataResponse<Any>) -> Result<[Traveller]>
    {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(ServerAPIManagerError.network(error: response.result.error!))
        }
        
        // check for "message" errors in the JSON because this API does that
        if  let jsonDictionary = response.result.value as? [String: Any],
            let errorMessage = jsonDictionary["message"] as? String
        {
            return .failure(ServerAPIManagerError.apiProvidedError(reason: errorMessage))
        }
        
        // make sure we got JSON Array
        guard let jsonArray = response.result.value as? [String:Any] else {
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        
        guard let travellers = jsonArray["success"] as? [Traveller] else {
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get an array with The users invited to the Trip Request"))
        }
        
        return .success(travellers)
    }

    
    //*************************************************************
    //MARK: Respond to Trip Request
    //*************************************************************
    func respondToTripRequest(completionHandler: @escaping (Result<[Traveller]>) -> Void)
    {
        
    }
    
    //*************************************************************
    //MARK: Cancel Trip Request
    //*************************************************************
    func cancelTripRequest(completionHandler: @escaping (Result<[Traveller]>) -> Void)
    {
        
    }
    
    
}








//----------------------------------
//MARK: ALlow Compression to UIImage
//----------------------------------

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    ///
    /// Returns a data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var pngData: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpegData(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}


