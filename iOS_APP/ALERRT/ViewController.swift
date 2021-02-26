//
//  ViewController.swift
//  Serial
//
//  Created by Bo Heyse on 9/13/19.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            // get the documents folder url
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // create the destination url for the text file to be saved
                let fileURL = documentDirectory.appendingPathComponent("file.txt")
                
                let savedText = try String(contentsOf: fileURL)
                print("savedText:", savedText)   // "Hello World !!!\n"
            }
        } catch {
            print("error:", error)
        }
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
