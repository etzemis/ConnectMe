//
//  JsonMappingObject.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation

class Todo {
    var title: String
    var id: Int?
    var userId: Int
    var completed: Bool
    
    required init?(title: String, id: Int?, userId: Int, completedStatus: Bool)
    {
        self.title = title
        self.id = id
        self.userId = userId
        self.completed = completedStatus }
    
    func description() -> String
    {
        return  "ID: \(self.id), \n" +
                "User ID: \(self.userId)\n" +
                "Title: \(self.title)\n" +
                "Completed: \(self.completed)\n"
    }
}
