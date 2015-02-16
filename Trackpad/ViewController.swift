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
    

    var peripheralManager : CBPeripheralManager!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        if peripheral.state == .PoweredOn {
            
            peripheralManager.addService(trackpadService())
        } else {
            println("State: \(peripheral.state)")
        }
    }
    
    func trackpadService() -> CBMutableService {
        
        println("Trackpad")
        let trackpadServiceUUID = CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
        var trackpadService = CBMutableService(type: trackpadServiceUUID, primary: true)
        
        trackpadService.characteristics = [trackingCharacteristic()]
        
        return trackpadService
    }
    
    func trackingCharacteristic() -> CBMutableCharacteristic {
        
        println("Tracking")
        let trackingCharacteristicUUID = CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
        let trackingCharacteristic = CBMutableCharacteristic(type: trackingCharacteristicUUID,
                                                             properties: CBCharacteristicProperties.Read,
                                                             value: nil,
                                                             permissions: CBAttributePermissions.Readable)
        
        return trackingCharacteristic
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        
        if error != nil {
            println("Error publishing service: \(error.localizedDescription)")
        }
        
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        
        if error != nil {
            println("Error advertsing service: \(error.localizedDescription)")
        }
    }
    


}

