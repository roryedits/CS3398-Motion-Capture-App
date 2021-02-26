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
//enum MessageOption: Int {
//    case noLineEnding,
//    newline,
//    carriageReturn,
//    carriageReturnAndNewline
//}

/// The option to add a \n to the end of the received message (to make it more readable)
//enum ReceivedMessageOption: Int {
//    case none,
//    newline
//}

final class DataViewController: UIViewController, UITextFieldDelegate, FileManagerDelegate {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            // get the documents folder url
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // create the destination url for the text file to be saved
                let fileURL = documentDirectory.appendingPathComponent(userSelectionScenario + "_" + userSelectionBodyPart + ".txt")
                let savedText = try String(contentsOf: fileURL)
                //print("savedText:", savedText)   // "Hello World !!!\n"
                mainTextView.text = savedText

            }
        } catch {
            print("error:", error)
        }
    }

}
