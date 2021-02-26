//
//  DataViewController.swift
//  Serial App
//
//  Created by Bo Heyse on 9/5/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import CoreData

var userSelectionScenario = ""


class ScenarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var scenarios: [NSManagedObject] = []
    var newScenario: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addScenario(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Scenario",
                                      message: "Add a Scenario name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func add(){
        var scenario = "Scenario" + String(ScenarioCount)
        self.save(name: scenario)
    }
    
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Scenario",
                                       in: managedContext)!
        
        let scenario = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        scenario.setValue(name, forKeyPath: "name")
        
        // 4
        do {
            try managedContext.save()
            scenarios.append(scenario)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (scenarios.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let scenario = scenarios[indexPath.row]
        cell.textLabel?.text = scenario.value(forKeyPath: "name") as? String
        return(cell)
    }
    
    // This is the function that sends the click to the DataViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
        print("Cell cliked value is \(indexPath.row)")
        let scenario = scenarios[indexPath.row]
        userSelectionScenario = (scenario.value(forKeyPath: "name") as? String)!
        print("User Selected: " + userSelectionScenario)
        
//        if(indexPath.row == 0)
//        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let controller = storyboard.instantiateViewController(withIdentifier: "BodyPartViewController") as! BodyPartViewController
            
            self.navigationController?.pushViewController(controller, animated: true)
            
//        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            //remove object from core data
            let managedContext =
                appDelegate.persistentContainer.viewContext
            managedContext.delete(scenarios[indexPath.row] as NSManagedObject)
            
            //update UI methods
            tableView.beginUpdates()
            scenarios.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            appDelegate.saveContext()
        }
    }
    
    @objc func startButtonHit(n : NSNotification){
        ScenarioCount += 1
        print("Start and Stop hit in sequence")
        //scenarios.append("Scenario " + String(scenarioCount))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scenarios Available"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(startButtonHit(n:)), name: Notification.Name(rawValue: "startButtonHit"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Scenario")
        
        //3
        do {
            scenarios = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getLengthScenarios() -> Int {
        return scenarios.count
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

//// MARK: - UITableViewDataSource
//extension ViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView,
//                   numberOfRowsInSection section: Int) -> Int {
//        return names.count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath)
//        -> UITableViewCell {
//
//            let cell =
//                tableView.dequeueReusableCell(withIdentifier: "cell",
//                                              for: indexPath)
//            cell.textLabel?.text = names[indexPath.row]
//            return cell
//    }
//}
