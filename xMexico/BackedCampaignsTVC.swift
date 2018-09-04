//
//  BackedCampaignsTVC.swift
//  xMexico
//
//  Created by Development on 7/27/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class BackedCampaignsTVC: UITableViewController {

	var backedCampaigns = [BackedCampaign]()
	
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
	override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector((SWRevealViewController.revealToggleMenu) as (SWRevealViewController) -> (Any?) -> Void) as Selector
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
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
        return self.backedCampaigns.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackedCampaignCell", for: indexPath) as! BackedCampaignTVCell
		cell.nameLabel.text = self.backedCampaigns[indexPath.row].name
		cell.amountLabel.text = self.backedCampaigns[indexPath.row].contributionAmount.description
		cell.statusLabel.text = self.backedCampaigns[indexPath.row].status
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
