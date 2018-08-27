//
//  ContributionViewController.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 8/24/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit

class ContributionViewController: UIViewController {

    @IBOutlet weak var contributeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var contributionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Action Methods
    
    @IBAction func contributePressed(_ sender: Any) {
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        let parent = self.parent as! CampaignVC
        parent.hideKeyboard()
        parent.hideContributionVC()
    }
    
}
