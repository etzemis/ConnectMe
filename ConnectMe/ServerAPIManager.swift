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
    

    //MARK: Public functions
    
   private func printAvailableUsers() -> Void {
        Alamofire.request(ConnectMeRouter.fetchTravellersAroundMe(1))
        .responseString { response in
            if let receivedString = response.result.value {
                print(receivedString)
            }
        }
    }
    
    func fetchTravellersAroundMe(completionHandler: @escaping (Result<[Traveller]>) -> Void)
    {
        Alamofire.request(ConnectMeRouter.fetchTravellersAroundMe(1))
            .responseJSON { response in
                let result = self.travellerArrayFromResponse(response:response)
                completionHandler(result)
        }
    }
    
    
    //MARK: Private functions - Parsing Responces
    
    // Extract an array of Travellers
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
        
        // turn JSON into gists
//        var travellers = [Traveler]()
//        for item in jsonArray {
//            if let gist = Gist(json: item) {
//                gists.append(gist)
//            }
//        }
        let travellers = jsonArray.flatMap{ Traveller(json: $0) }
        return .success(travellers)
    }

}
