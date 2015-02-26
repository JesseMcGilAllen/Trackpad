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
    
    var beginTrackingCharacteristic : CBMutableCharacteristic!
    var trackingCharacteristic : CBMutableCharacteristic!
    var screenSizeCharacteristic : CBMutableCharacteristic!
    
    
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
        instantiateScreenSizeCharacteristic()
        instantiateBeginTrackingCharacteristic()
        trackpadService.characteristics = [screenSizeCharacteristic, beginTrackingCharacteristic, trackingCharacteristic]
        
        return trackpadService
    }
    
    func beginTrackingCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "E0A13890-5CAB-4763-863C-B639132CE144")
    }
    
    func instantiateBeginTrackingCharacteristic() {
        
        beginTrackingCharacteristic = CBMutableCharacteristic(type: beginTrackingCharacteristicUUID(),
            properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.NotifyEncryptionRequired,
            value: nil, permissions: CBAttributePermissions.ReadEncryptionRequired)
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
    
    func screenSizeCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "92241F88-3A7E-4DEA-8DE5-12066D690250")
    }
    
    func instantiateScreenSizeCharacteristic() {
        
        screenSizeCharacteristic = CBMutableCharacteristic(type: screenSizeCharacteristicUUID(),
                                                           properties: CBCharacteristicProperties.Read,
                                                           value: screenSizeData(),
                                                           permissions: CBAttributePermissions.ReadEncryptionRequired)


    }
    
    func screenSizeData() -> NSData {
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenString = NSStringFromCGRect(screenRect)
        
        return screenString.dataUsingEncoding(NSUTF8StringEncoding)!
        
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
        
        if sender.state == .Began {
            
            let didSendValue = peripheralManager.updateValue(data, forCharacteristic: beginTrackingCharacteristic, onSubscribedCentrals: nil)
            
        } else {
            
            let didSendValue = peripheralManager.updateValue(data, forCharacteristic: trackingCharacteristic, onSubscribedCentrals: nil)
            
        }
        
        
        
           
    }
    
}

