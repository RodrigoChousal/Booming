//
//  SearchTableViewController.swift
//  xMexico
//
//  Created by Development on 6/23/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, CustomSearchControllerDelegate {
    
    var customSearchController: CustomSearchController!
    var searchController: UISearchController!
    var shouldShowSearchResults = Bool()

    var campaignsArray = [Campaign]()
    var filteredNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Buscar"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        configureCustomSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults {
            return filteredNames.count
        } else {
            return campaignsArray.count
        }
        
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResults", for: indexPath)

        cell.textLabel?.font = UIFont(name: "Futura", size: 15)
        
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredNames[indexPath.row]
        } else {
            cell.textLabel?.text = campaignsArray[indexPath.row].name
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let campaignDetailVC = segue.destination as! CampaignVC
        
        let cell = sender as! UITableViewCell
        let campaignName = cell.textLabel?.text
        
        for campaign in campaignsArray {
            if campaign.name == campaignName {
                campaignDetailVC.campaign = campaign
                continue
            }
        }
    }
    
    // MARK: - UISearchBar Delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for: UISearchController) {
        
        let searchString = searchController.searchBar.text
        
        var campaignNames = [String]()
        for campaign in campaignsArray {
            campaignNames.append(campaign.name)
        }
        
        filteredNames = campaignNames.filter { term in
            return term.lowercased().contains((searchString?.lowercased())!)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - CustomSearchControllerDelegate Delegate
    
    func didStartSearching() {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        
        var campaignNames = [String]()
        for campaign in campaignsArray {
            campaignNames.append(campaign.name)
        }
        
        filteredNames = campaignNames.filter { term in
            return term.lowercased().contains((searchText.lowercased()))
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Helper Methods
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: "Avenir-Light", size: 16.0)!, searchBarTextColor: .black, searchBarTintColor: .white)
        
        customSearchController.customSearchBar.placeholder = "Buscar una campaña en específico..."
        tableView.tableHeaderView = customSearchController.customSearchBar
        
        customSearchController.customDelegate = self
    }

}
