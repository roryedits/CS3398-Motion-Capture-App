//
//  ViewController.swift
//  ATGoogleDriveDemo
//
//  Created by Dejan on 09/04/2018.
//  Copyright © 2018 Dejan. All rights reserved.
//
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import CoreData

class GoogleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var selectLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    var scenarios: [NSManagedObject] = []
    var selectedScenario = ""
    var changeProgress = false
    
    fileprivate let service = GTLRDriveService()
    private var drive: ATGoogleDrive?
    var btnGoogleSignIn: GIDSignInButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.title = "Last Recording: Scenario" + String(ScenarioCount)
        
        //self.selectLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 50))
        self.selectLabel.text = "Please Select a Scenario to Upload"
        setupGoogleSignIn()
        
        drive = ATGoogleDrive(service)
        
        self.btnGoogleSignIn = GIDSignInButton(frame: CGRect(x: 0, y: 750, width: self.view.frame.width, height: 50))
        self.view.addSubview(self.btnGoogleSignIn!)
        
        view.addSubview(GIDSignInButton())
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
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scenarios.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if scenarios.count != 0{
            let scenario = scenarios[row]
            return(scenario.value(forKeyPath: "name") as? String)
        }
        else{
            print("No scenarios available")

                return "No Scenarios Available"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if scenarios.count != 0{
            selectedScenario = scenarios[row].value(forKeyPath: "name") as? String ?? "No Selection"
            print(selectedScenario)
        }
    }
    
    private func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveFile]
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    @objc func uploadHead() {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let testFilePath = documentsDir.appendingPathComponent(selectedScenario + "_" + body_parts[0] + ".txt").path
            let new = selectedScenario.prefix(0) + "$" + selectedScenario.dropFirst(1)
            print(String(new))
            drive?.uploadFile(String(new), filePath: testFilePath, MIMEType: "file/txt") { (fileID, error) in
                print("Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
            }
        }
        changeProgress = true
    }
    
    @objc func uploadGun() {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let testFilePath = documentsDir.appendingPathComponent(selectedScenario + "_" + body_parts[1] + ".txt").path
            let new = selectedScenario.prefix(0) + "$" + selectedScenario.dropFirst(1)
            print(String(new))
            drive?.uploadFile(String(new), filePath: testFilePath, MIMEType: "file/txt") { (fileID, error) in
                print("Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
            }
        }
        changeProgress = true
    }
    
    @objc func uploadChest(progressView: UIProgressView) {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let testFilePath = documentsDir.appendingPathComponent(selectedScenario + "_" + body_parts[2] + ".txt").path
            let new = selectedScenario.prefix(0) + "$" + selectedScenario.dropFirst(1)
            print(String(new))
            drive?.uploadFile(String(new), filePath: testFilePath, MIMEType: "file/txt") { (fileID, error) in
                print("Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
            }
        }
        changeProgress = true
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.disconnect()
    }
    
    // MARK: - Actions
    @IBAction func uploadAction(_ sender: Any) {
        
        let alertView = UIAlertController(title: "Upload", message: "Uploading Files in: " + selectedScenario, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        //  Show it to your users
        present(alertView, animated: true, completion: {
            //  Add your progressbar after alert is shown (and measured)
//            let margin:CGFloat = 8.0
//            let rect = CGRect(x: margin, y: 72.0, width: alertView.view.frame.width - margin * 2.0 , height: 2.0)
//            let progressView = UIProgressView(frame: rect)
//            progressView.progress = 0.0
//            var progress = Float(0.0)
//            progressView.tintColor = UIColor.blue
//            alertView.view.addSubview(progressView)
            print(self.changeProgress)
            })
        
        self.perform(#selector(self.uploadHead), with: nil, afterDelay: 1.0)
        self.perform(#selector(self.uploadGun), with: nil, afterDelay: 5.0)
        
        self.perform(#selector(self.uploadChest), with: nil, afterDelay: 9.0)
    }
}

// MARK: - GIDSignInDelegate
extension GoogleViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }
}

// MARK: - GIDSignInUIDelegate
extension GoogleViewController: GIDSignInUIDelegate {}
