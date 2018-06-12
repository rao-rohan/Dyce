//
//  SettingsTableVC.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 1/21/18.
//  Copyright © 2018 Applausity Inc. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableVC: UITableViewController {
    
    //outlets
    @IBOutlet weak var logoutBtn: UIButton!
    
    //map used to find the setting type based on an indexPath
    var indexPathToType = [[Int: SettingsType]]()
    //map used to find the segue name based on an indexPath
    var indexPathToSegue = [[Int: String]]()
    
    //the selected cell's setting type
    var selectedType: SettingsType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rounds buttons
        logoutBtn.layer.masksToBounds = true
        logoutBtn.layer.cornerRadius = logoutBtn.frame.size.width/10
        
        //initializes indexPathToType map
        indexPathToType = [[0: .username, 1: .email, 2: .password], [0: .none, 1: .none, 2: .none]]
        
        let oneCell = NameFile.Segues.Profile.toOneCellSettingDetail
        let threeCell = NameFile.Segues.Profile.toThreeCellSettingDetail
        
        //initializes indexPathToSegue map
        indexPathToSegue = [[0: oneCell, 1: oneCell, 2: threeCell], [0: "support", 1: "privacypolicy", 2: "termsofservice"]]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCellDetailTexts()
    }

    //MARK: - Helper Methods
    
    @IBAction func logout(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Intro", bundle: nil)
            if let introIVC = storyboard.instantiateInitialViewController(){
                self.present(introIVC, animated: true, completion: nil)
            }
        }catch{
            print("Error while signing out")
        }
    }
    
    private func updateCellDetailTexts(){
        var counter = 0
        for cell in tableView.visibleCells{
            if let detailLabel = cell.viewWithTag(1) as? UILabel{
                switch counter{
                case 0:
                    detailLabel.text = AppStorage.PersonalInfo.username
                case 1:
                    detailLabel.text = AppStorage.PersonalInfo.email
                case 2:
                    let origPass = "••••••••••••••••••••••••••••••••••••••••••••••"
                    let offset: Int = AppStorage.PersonalInfo.password.count
                    let end = origPass.index(origPass.startIndex, offsetBy: offset)
                    detailLabel.text = String(origPass[origPass.startIndex..<end])
                default:
                    break
                }
            }
            counter += 1
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if(indexPathToSegue[indexPath.section][indexPath.row] == "notselectable"){
            return nil
        }
        if(indexPathToSegue[indexPath.section][indexPath.row] == "support"){
            //directs user to the website to view support info
            UIApplication.shared.open(URL(string : "http://nFinitylabs.org")!, options: [:], completionHandler: { (status) in
            })
            return nil
        }
        else if(indexPathToSegue[indexPath.section][indexPath.row] == "privacypolicy"){
            //directs user to the website to view privacy policy
            UIApplication.shared.open(URL(string : "http://nFinitylabs.org")!, options: [:], completionHandler: { (status) in
            })
            return nil
        }
        if(indexPathToSegue[indexPath.section][indexPath.row] == "termsofservice"){
            //directs user to the website to view terms of service
            UIApplication.shared.open(URL(string : "http://nFinitylabs.org")!, options: [:], completionHandler: { (status) in
            })
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedType = (indexPathToType[indexPath.section][indexPath.row]!)
        performSegue(withIdentifier: indexPathToSegue[indexPath.section][indexPath.row]!, sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }
        if section == 1{
            return 3
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "MY ACCOUNT"
        }
        if section == 1{
            return "OTHER INFO"
        }
        return nil
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {}
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //sets the destination to the selectedType
        if let detailVC = segue.destination as?  SettingsDetailVC1{
            detailVC.type = selectedType
        }
        if let detailVC = segue.destination as? SettingsDetailVC3{
            detailVC.type = selectedType
        }
    }
    
    
}


enum SettingsType{
    case username
    case email
    case password
    case none
}
