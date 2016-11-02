//
//  AlmofireRouter.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import Alamofire

enum ConnectMeRouter: URLRequestConvertible {
    static let baseURLString = "https://jsonplaceholder.typicode.com/"
    // posting
    case updateLocation([String: Any])
    case insertDestination([String: Any])
    // fetching  - Posting my User Id
    //will return a list of IDs
    case fetchTravellersAroundMe(Int)
    // Provide an ID, then the User Datawill be returned
    case fetchTraveller(Int)
    
    func asURLRequest() throws -> URLRequest { // TODO: implement
        var method: HTTPMethod {
            switch self {
            case .updateLocation:
                return .post
            case .insertDestination:
                return .post
            case .fetchTravellersAroundMe:
                return .get
            case .fetchTraveller:
                return .get
            }
        }
        
        let params: ([String: Any]?) = {
            switch self {
            case .updateLocation(let newLocation):
                return (newLocation)
            case .insertDestination(let newDestination):
                return (newDestination)
            case .fetchTravellersAroundMe:
                return nil
            case .fetchTraveller:
                return nil
            }
        }()
        
        
        let url: URL = {
            // build up and return the URL for each endpoint
            let relativePath: String?
            switch self {
            case .updateLocation:
                relativePath = "location"
            case .insertDestination:
                relativePath = "destination"
            case .fetchTravellersAroundMe(let id):
                relativePath = "travellers/\(id)"
            case .fetchTraveller(let travellerId):
                relativePath = "traveller/\(travellerId)"
            }
            
            var url = URL(string: ConnectMeRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        //create mutable request using the URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        //Then we encode any parameters and add them to the request.
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
}
