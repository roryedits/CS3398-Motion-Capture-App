//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

let scenarioViewController = ScenarioViewController()
var ScenarioCount = scenarioViewController.getLengthScenarios()


final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate, FileManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(ScenarioCount)
        if serial.connectedPeripherals.count == 0 {
            return 1
        }
        else{
            return serial.connectedPeripherals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("number of connections " + String(serial.connectedPeripherals.count))
        if serial.connectedPeripherals.count != 0 {
            // return a cell with the peripheral name as text in the label
            peripherals = serial.connectedPeripherals
            let cell = tableView.dequeueReusableCell(withIdentifier: "connectCell")!
            let label = cell.viewWithTag(1) as! UILabel
            label.text = peripherals[(indexPath as NSIndexPath).row].name
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "disconnectCell")!
            let label = cell.viewWithTag(1) as! UILabel
            label.text = "No Connected Devices"
            return cell
        }
    }
//MARK: IBOutlets
    
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var peripherals : [CBPeripheral] = []
    
    
    
    var start = false
    var stop = false
    
    @IBAction func startRecording(_ sender: UIButton) {
        let msg = "1"
        serial.sendMessageToDevice(msg)
        print("start clicked")
        start = true
       // print("start clicked")
    }

    let ScenarioView = ScenarioViewController()
    @IBAction func stopRecording(_ sender: UIButton) {
        let msg = "2"
        serial.sendMessageToDevice(msg)
        stop = true
        ScenarioCount += 1
        print("value of stop: " + String(stop))
        print("value of start: " + String(start))
        if stop && start {

            scenarioViewController.add()
            print("Scenario" + String(ScenarioCount) + " added")
            start = false
        }
        stop = false
        print("stop clicked")
    }
    
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init serial
        serial = BluetoothSerial(delegate: self)        
        // UI
        mainTextView.text = ""
        reloadView()
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        // we want to be notified when the keyboard is shown (so we can move the textField up)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(SerialViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // style the bottom UIView
        bottomView.layer.masksToBounds = false
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomView.layer.shadowRadius = 0
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowColor = UIColor.gray.cgColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // animate the text field to stay above the keyboard
        var info = (notification as NSNotification).userInfo!
        let value = info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        //TODO: Not animating properly
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
            }, completion: { Bool -> Void in
            self.textViewScrollToBottom()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // bring the text field back down..
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = 0
        }, completion: nil)

    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        tableView.reloadData()
        
        if serial.isReady {
            navItem.title = "Scenario: " + String(ScenarioCount+1)
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn && serial.connectedPeripherals.count == 0 {
            navItem.title = "Scenario: " + String(ScenarioCount+1)
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        }
          else {
            navItem.title = "Scenario: " + String(ScenarioCount+1)
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        }
    }
    
    func textViewScrollToBottom() {
        let range = NSMakeRange(NSString(string: mainTextView.text).length - 1, 1)
        mainTextView.scrollRangeToVisible(range)
    }
    

//MARK: BluetoothSerialDelegate
    var headReceived = false
    var chestReceived = false
    var head = ""
    var chest = ""
    
    func serialDidReceiveString(_ message: String) {
        print(message)
        if message.contains("Head"){
            headReceived = true
            print("Got a message from Head")
            
        }
        else if message.contains("Chest"){
            chestReceived = true
            
        }
        
        if headReceived{
            do {
                if message.contains("Next"){
                    headReceived = false
                    serial.sendMessageToDevice("B")
                    print("sent B")
                }
                else{
                // get the documents folder url
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    // create the destination url for the text file to be saved
                    let fileURL = documentDirectory.appendingPathComponent("Scenario" + String(ScenarioCount) + "_Head.txt")
                    // define the string/text to be saved
                    head += message
                    // writing to disk
                    // Note: if you set atomically to true it will overwrite the file if it exists without a warning
                    try head.write(to: fileURL, atomically: false, encoding: .utf8)
                    // reading from disk
                    //                let savedText = try String(contentsOf: fileURL)
                    //                print("savedText:", savedText)   // "Hello World !!!\n"
                    }
                }
            } catch {
                print("error:", error)
            }
        }
        
        if chestReceived{
            do {
                if message.contains("Next"){
                    chestReceived = false
                    serial.sendMessageToDevice("A")
                    print("sent A")
                }
                else{
                // get the documents folder url
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    // create the destination url for the text file to be saved
                    let fileURL = documentDirectory.appendingPathComponent("Scenario" + String(ScenarioCount) + "_Chest.txt")
                    // define the string/text to be saved
                    chest += message
                    // writing to disk
                    // Note: if you set atomically to true it will overwrite the file if it exists without a warning
                    try chest.write(to: fileURL, atomically: false, encoding: .utf8)
                    // reading from disk
                    //                let savedText = try String(contentsOf: fileURL)
                    //                print("savedText:", savedText)   // "Hello World !!!\n"
                    }
                }
            } catch {
                print("error:", error)
            }
        }
        mainTextView.text! += message

//        let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
//        if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
//        do {
//            // get the documents folder url
//            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                // create the destination url for the text file to be saved
//                let fileURL = documentDirectory.appendingPathComponent("file.txt")
//                // define the string/text to be saved
//                let text = mainTextView.text!
//                // writing to disk
//                // Note: if you set atomically to true it will overwrite the file if it exists without a warning
//                try text.write(to: fileURL, atomically: false, encoding: .utf8)
//                //print("saving was successful")
//                // any posterior code goes here
//                // reading from disk
////                let savedText = try String(contentsOf: fileURL)
////                print("savedText:", savedText)   // "Hello World !!!\n"
//            }
//        } catch {
//            print("error:", error)
//        }
        textViewScrollToBottom()
        
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //tableView.reloadData()
        //reloadView()
        dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
        //tableView.reloadData()
        
        peripherals.removeAll()
        serial.disconnect()
        reloadView()
    }
    
    func serialDidChangeState() {
        //tableView.reloadData()
        reloadView()
        if serial.centralManager.state != .poweredOn {
            dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    
//MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !serial.isReady {
            let alert = UIAlertController(title: "Not connected", message: "What am I supposed to send this to?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
            present(alert, animated: true, completion: nil)
            messageField.resignFirstResponder()
            return true
        }
        
        // send the message to the bluetooth device
        // but fist, add optionally a line break or carriage return (or both) to the message
        let pref = UserDefaults.standard.integer(forKey: MessageOptionKey)
        var msg = messageField.text!
        switch pref {
        case MessageOption.newline.rawValue:
            msg += "\n"
        case MessageOption.carriageReturn.rawValue:
            msg += "\r"
        case MessageOption.carriageReturnAndNewline.rawValue:
            msg += "\r\n"
        default:
            msg += ""
        }
        
        // send the message and clear the textfield
        serial.sendMessageToDevice(msg)
        messageField.text = ""
        return true
    }
    
    @objc func dismissKeyboard() {
        messageField.resignFirstResponder()
    }
    
    
//MARK: IBActions

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            peripherals.removeAll()
            serial.disconnect()
            reloadView()
        }
    }
}
