//
//  ServerAPIManager.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import Alamofire
// Class Responsible for the API Interactions
class ServerAPIManager {
    static let sharedInstance = ServerAPIManager()
    
    
//MARK: Check Authorization
    func checkUnauthorized(urlResponse: HTTPURLResponse) -> (Error?) {
        if (urlResponse.statusCode == 401) {
            return ServerAPIManagerError.authLost(reason: "Not Logged In")
        }
        return nil
    }
    
//MARK: Fetch Images
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
    
//MARK: Clear Alamofire Cache
    
    /// Alamofire uses the default URLCache to cache the URL responses so we need to flush out the cache before refreshing. 
    /// Otherwise we’ll just get the cached response and won’t see any new gists. 
    /// To implement clearing the cache we can use removeAllCachedResponses() on the shared URL cache.
    func clearCache() -> Void {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
    
    
    
    
    
    
//MARK: User Registration
    func register(username: String,
                  email: String,
                  password: String,
                  profileImage: UIImage?,
                  address: String,
                  completionHandler: @escaping (Result<Bool>) -> Void)
    {
        
        //First Create JSON Object that you will be sending to the Server
        let parameters: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "address": address,
            "profile_photo": "myimage"
        ]
        
        let request = Alamofire.request(ConnectMeRouter.register(parameters))
            .response { response in
                guard response.error == nil else {
                    print(response.error!)
                    completionHandler(.failure(response.error!))
                    return
                }
                //Otherwise Success
                completionHandler(.success(true))
        }
        print("\n\n\n\n  Registration request \n\n\n\n")
        debugPrint(request)
    }
    
    
    
    
    
    
    
    
    
    
//MARK: User Login
    func login(email: String,
               password: String,
               completionHandler: @escaping (Result<String>) -> Void)
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
    private func tokenFromResponse(response: DataResponse<Any>) -> Result<String>
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
        
        return .success(jsonKey["token"] as! String)
    }



    

//MARK: Update Location
    func updateLocation(location: Location,
                        completionHandler: @escaping (Result<Bool>) -> Void)
    {
        //First Create JSON Object that you will be sending to the Server
        let parameters: [String: Any] = location.toJSON()
        
        let request = Alamofire.request(ConnectMeRouter.updateLocation(parameters))
            .response { response in
                guard response.error == nil else {
                    print(response.error!)
                    completionHandler(.failure(response.error!))
                    return
                }
                //Otherwise Success
                completionHandler(.success(true))
        }
        print("\n\n\n\n  Update Location Request \n\n\n\n")
        debugPrint(request)
    }

                        
    
    
    
    
//MARK: Fetch Travellers Around Me
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
        
        // make sure we got JSON and it's an array
        guard let jsonArray = response.result.value as? [[String: Any]] else {
            print("Didn't get array of Travellers as JSON from API")
            return .failure(ServerAPIManagerError.objectSerialization(reason:"Did not get JSON dictionary in response"))
        }
        
        let travellers = jsonArray.flatMap{ Traveller(json: $0) }
        return .success(travellers)
    }
    

    
//MARK: Insert Destination
    func insertDestination(destination: Location, extraPersons: Int, completionHandler: @escaping (Result<Bool>) -> Void)
    {
        
        //First Create JSON Object that you will be sending to the Server
        var parameters: [String: Any] = destination.toJSON()
        parameters["extraPersons"] = extraPersons  // add the extraPersons Parameter
        
        let request = Alamofire.request(ConnectMeRouter.insertDestination(parameters))
            .responseJSON { response in
                if  let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse: urlResponse)
                {
                    print("\n AuthorizationError in FetchTravellersAroundMe \n")
                    completionHandler(.failure(authError))
                    return
                }
                
                guard response.result.error == nil else {
                    print(response.result.error!)
                    completionHandler(.failure(ServerAPIManagerError.network(error: response.result.error!)))
                    return
                }
                //Otherwise Success
                completionHandler(.success(true))
        }
        
        print("\n\n\n\n  Insert Destination request \n\n\n\n")
        debugPrint(request)
    }
    
}


