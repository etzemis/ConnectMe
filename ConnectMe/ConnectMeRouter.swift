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
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let baseURLString = "https://jsonplaceholder.typicode.co/"
    // posting
    case register([String: Any])
    case updateLocation([String: Any])
    case insertDestination([String: Any])
    // fetching
    case fetchTravellersAroundMe()

    
    func asURLRequest() throws -> URLRequest { // TODO: implement
        var method: HTTPMethod {
            switch self {
            case .register:
                return .post
            case .updateLocation:
                return .post
            case .insertDestination:
                return .post
            case .fetchTravellersAroundMe:
                return .get
            }
        }
        
        let params: ([String: Any]?) = {
            switch self {
            case .register(let userInfo):
                return (userInfo)
            case .updateLocation(let newLocation):
                return (newLocation)
            case .insertDestination(let newDestination):
                return (newDestination)
            case .fetchTravellersAroundMe:
                return nil
            }
        }()
        
        
        let url: URL = {
            // build up and return the URL for each endpoint
            let relativePath: String?
            switch self {
            case .register:
                relativePath = "register"
            case .updateLocation:
                relativePath = "location"
            case .insertDestination:
                relativePath = "destination"
            case .fetchTravellersAroundMe:
                relativePath = "travellers"

            }
            
            var url = URL(string: ConnectMeRouter.baseURLString)!
            if let relativePath = relativePath {
                url = url.appendingPathComponent(relativePath)
            }
            return url
        }()
        
        //create mutable request using the URLServer
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        //Create Basic Authentication
        let defaults  = UserDefaults.standard
        let username = defaults.string(forKey: AppDelegate.Constants.EmailUserDefaults)
        let password = defaults.string(forKey: AppDelegate.Constants.PasswordUserDefaults)
        
        if let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8) {
            let base64Credentials = credentialData.base64EncodedString()
            urlRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        //Then we encode any parameters and add them to the request.
        let encoding = JSONEncoding.default
        return try encoding.encode(urlRequest, with: params)
    }
}
