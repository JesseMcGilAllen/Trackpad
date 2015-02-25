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
    var trackingCharacteristic : CBMutableCharacteristic!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Required to conform to CBPeripheralManagerDelegate Protocol
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        if peripheral.state == .PoweredOn {
            
            peripheralManager.addService(trackpadService())
    
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [trackpadServiceUUID()]])
            
        } else {
            
            println("State: \(peripheral.state)")
        }
    }
    
    // MARK: Services & Characteristics
    
    func trackpadServiceUUID() -> CBUUID {
        return CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    }
    
    func trackpadService() -> CBMutableService {
        
        
        var trackpadService = CBMutableService(type: trackpadServiceUUID(), primary: true)
        instantiateTrackingCharacteristic()
        trackpadService.characteristics = [trackingCharacteristic]
        
        return trackpadService
    }
    
    func trackingCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
    }
    
    func instantiateTrackingCharacteristic() {
        
        trackingCharacteristic = CBMutableCharacteristic(type: trackingCharacteristicUUID(),
                                                             properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.NotifyEncryptionRequired,
                                                             value: nil,
                                                             permissions: CBAttributePermissions.ReadEncryptionRequired)
        
    }
    
    // MARK: Peripheral Manager
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        
        if error != nil {
            println("Error publishing service: \(error.localizedDescription)")
        }
        
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        
        if error != nil {
            println("Error advertising service: \(error.localizedDescription)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        
        println("Central subscribed to characteristic: \(characteristic)")
        println(central.maximumUpdateValueLength)

    }
    
    // MARK: Gestures
    
    @IBAction func panDetected(sender: UIPanGestureRecognizer) {
        
        var location = sender.locationInView(self.view)
    
        var locationString = NSStringFromCGPoint(location)
        var data = locationString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let didSendValue = peripheralManager.updateValue(data, forCharacteristic: trackingCharacteristic, onSubscribedCentrals: nil)
        
        println("Sent?: \(didSendValue)")
   
    }
    
}

