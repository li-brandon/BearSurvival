//
//  LostViewController.swift
//  NormalApp
//
//  Created by Brandon Li on 12/5/21.
//

import UIKit
import RealityKit

class LostViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.red
        print("opened")
        
        let lostLabel = UILabel(frame: CGRect(x: 350, y: 500, width: 300, height: 40))
        
        lostLabel.text = "You Lost!"
        lostLabel.textColor = UIColor.black
        lostLabel.font = UIFont(name:"Arial", size: 30)
        
        self.view.addSubview(lostLabel)
        // Do any additional setup after loading the view.
    }
}
