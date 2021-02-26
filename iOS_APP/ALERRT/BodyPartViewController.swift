//
//  BodyPartViewController.swift
//  Serial
//
//  Created by Bo Heyse on 9/11/19.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

let body_parts = ["Head", "Gun", "Chest"]
var userSelectionBodyPart = ""

class BodyPartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (body_parts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = body_parts[indexPath.row]
        
        return(cell)
    }
    
    // This is the function that sends the click to the DataViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
        print("Cell cliked value is \(indexPath.row)")
        let bodyPart = body_parts[indexPath.row]
        userSelectionBodyPart = bodyPart
        print("User Selected: " + userSelectionBodyPart)

        
        if(indexPath.row <= 4)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let controller = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
        }

    }
    
//    // This is the function that sends the click to the DataViewController
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You tapped cell number \(indexPath.section).")
//        print("Cell cliked value is \(indexPath.row)")
//
//        if(indexPath.row == 0)
//        {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            let controller = storyboard.instantiateViewController(withIdentifier: "BodyPartViewController") as! BodyPartViewController
//
//            self.navigationController?.pushViewController(controller, animated: true)
//
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */


}
