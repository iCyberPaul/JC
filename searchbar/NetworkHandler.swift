//
//  NetworkHandler.swift
//  searchbar
//
//  Created by Paul Beattie on 07/08/2017.
//  Copyright © 2017 Paul Beattie. All rights reserved.
//

import Foundation

// A list of all the network calls.
enum NetworkNames : String {
    case search = "searchForRecipe"
}

class NetworkHandler {
    
    var entriesLimit = 20
    var url = "http://www.recipepuppy.com/api/"

    
    func obtainRecipies(containing searchTerm:String) {
        let preUrlString = url.appending("?q=\(searchTerm)")
        if let urlString = URL(string:preUrlString) {
            do {
                let data = try Data(contentsOf: urlString, options:.alwaysMapped)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String,AnyObject>
                    print("jaon = \(json)")
                    var recipeArray = [String]()
                    
                    if let individualDataDictionay = json["results"] {
                        let individualDataDictionryArray = individualDataDictionay as! Array<AnyObject>
                        for (count, recipeInfo) in individualDataDictionryArray.enumerated() {
                            if count < entriesLimit {
                                let recipe = recipeInfo["title"] as? String ?? ""
                                recipeArray.append(recipe)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(NetworkNames.search.rawValue), object: self, userInfo: [NetworkNames.search.rawValue:recipeArray])
                    }
                } catch {
                    print("failed to convert data to json")
                }
                
            } catch {
                print("Failed to get data")
            }
        }
        
    }
    
    
    
}
