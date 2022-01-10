//
//  WonViewController.swift
//  NormalApp
//
//  Created by Brandon Li on 12/5/21.
//

import UIKit
import RealityKit

class WonViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.green
        print("opened")
        
        let wonLabel = UILabel(frame: CGRect(x: 350, y: 500, width: 300, height: 40))
        
        wonLabel.text = "You Won!"
        wonLabel.textColor = UIColor.black
        wonLabel.font = UIFont(name:"Arial", size: 30)
        
        self.view.addSubview(wonLabel)
        // Do any additional setup after loading the view.
    }
}
