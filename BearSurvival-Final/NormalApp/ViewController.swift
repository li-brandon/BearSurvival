//
//  ViewController.swift
//  NormalApp
//
//  Created by Kelly Ma on 12/1/21.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func goAR(_ sender: Any) {
        print("clicked AR")
        let ARVC = ARViewController()
        
        navigationController?.pushViewController(ARVC, animated: true)
    }
    
    @IBAction func closeOverlay(_ sender: Any) {
        overlay = false
        dismiss(animated: true, completion: nil)
        print("already has overlay")
    }
    
    @IBAction func howToPlay(_ sender: Any) {
        print("How to Play")
        
        // Segue Transition - https://stackoverflow.com/questions/27094923/swift-navigate-to-new-viewcontroller-using-button
        self.performSegue(withIdentifier: "gameInstructions", sender: self)
    }
    
}
