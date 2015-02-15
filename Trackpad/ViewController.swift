//
//  ViewController.swift
//  Trackpad
//
//  Created by Jesse McGil Allen on 2/11/15.
//  Copyright (c) 2015 Jesse McGil Allen. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    

    let peripheralManager : CBPeripheralManager!
    
    required init(coder aDecoder: NSCoder) {
        peripheralManager = CBPeripheralManager()
        super.init(coder: aDecoder)
        
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralManager.delegate = self
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("State: \(peripheral.state.rawValue)")
    }
    
    


}

