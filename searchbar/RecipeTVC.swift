//
//  RecipeTVC.swift
//  searchbar
//
//  Created by Paul Beattie on 07/08/2017.
//  Copyright © 2017 Paul Beattie. All rights reserved.
//

import UIKit

class RecipeTVC: UIViewController {
    
    // The search controller containing doing the filtering
    var searchController = UISearchController()
    // The tableview used to display the filtered results.
    let resultsTableViewController = UITableViewController()
    
    @IBOutlet weak var fullListTableView: UITableView!
    
    
    // The raw data
    let tempResults = [String]() // ["pie", "custard", "omlete", "boiled Egg", "scrambled egg", "salmon"]
    // A holder for the filtered results.
    var filteredRecipeResults = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // The search controller is to use the resultsTableViewController to display its results.
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        fullListTableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        
        // These need to be added as the this tableview was not added in a storyboard
        resultsTableViewController.tableView.dataSource = self
        resultsTableViewController.tableView.delegate = self
        fullListTableView.dataSource = self
        fullListTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRecipies(notification:)), name: NSNotification.Name(rawValue: NetworkNames.search.rawValue), object: nil)

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension RecipeTVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == fullListTableView {
            return tempResults.count
        } else {
            return filteredRecipeResults.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == fullListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
            cell.textLabel?.text = tempResults[indexPath.row]
            return cell
            
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = filteredRecipeResults[indexPath.row]
            return cell
        }
        
    }
    
}

extension RecipeTVC: UITableViewDelegate {
    
}

extension RecipeTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchTerm = searchController.searchBar.text {
            let nh = NetworkHandler()
            nh.obtainRecipies(containing: searchTerm)
        }
        
    }
    
    @objc func receiveRecipies(notification:NSNotification) {
    
        let userInfo = notification.userInfo!
        
        for (key, value ) in userInfo as! [String:Any] {
            switch key {
            case NetworkNames.search.rawValue :
                filteredRecipeResults = value as! [String]

            default : break
            }
        }
    
//        filteredRecipeResults = tempResults.filter({ (stringValue:String) -> Bool in
//            if stringValue.lowercased().contains((searchController.searchBar.text?.lowercased())!) {
//                return true
//            } else {
//                return false
//            }
//        })
        resultsTableViewController.tableView.reloadData()
    }
    
}

