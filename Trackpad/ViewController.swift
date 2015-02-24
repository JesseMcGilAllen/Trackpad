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
    
    let trackpadServiceUUID = CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    var peripheralManager : CBPeripheralManager!
    var isCentralReady = false
    var subscribedCentrals = [CBCentral]()
    var trackingCharacteristic : CBMutableCharacteristic!
    
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
    
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [trackpadServiceUUID]])
            
        } else {
            
            println("State: \(peripheral.state)")
        }
    }
    
    func trackpadService() -> CBMutableService {
        
        
        var trackpadService = CBMutableService(type: trackpadServiceUUID, primary: true)
        instantiateTrackingCharacteristic()
        trackpadService.characteristics = [trackingCharacteristic]
        
        return trackpadService
    }
    
    func instantiateTrackingCharacteristic() -> CBMutableCharacteristic {
        
        let trackingCharacteristicUUID = CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
        trackingCharacteristic = CBMutableCharacteristic(type: trackingCharacteristicUUID,
                                                             properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.NotifyEncryptionRequired,
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
            println("Error advertising service: \(error.localizedDescription)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        
        println("Central subscribed to characteristic: \(characteristic)")
        isCentralReady = true
        subscribedCentrals.append(central)
       println(central.maximumUpdateValueLength)
        
        testConnection()

    }
    
    func testConnection() {
        var test = "Hello World"
        
        // let testData = test.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) as NSData!
        
        // characteristic.value = testData
        
        let characteristic = trackingCharacteristic
        
        let data = NSData(bytes: &test, length: sizeofValue(test))
        println("Bytes: \(data.length)")
        let didSendValue = peripheralManager.updateValue(data, forCharacteristic: trackingCharacteristic, onSubscribedCentrals: nil)
        println("Sent?: \(didSendValue)")
        
        println(characteristic.value)
        
//        if let testString = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding) as NSString! {
//            println(testString)
//        }

    }
    
    @IBAction func panDetected(sender: UIPanGestureRecognizer) {
        
        var translation = sender.translationInView(self.view.superview!)
        
        let location = sender.locationInView(self.view)
        
        let translationArray = [translation.x, translation.y]
        let characteristic = trackingCharacteristic
        
        // var updatedData = NSKeyedArchiver.archivedDataWithRootObject(translationArray)
        let pairToSend = (Double(translation.x), Double(translation.y))
        let data = NSData(bytes: &translation, length: sizeofValue(pairToSend))
        // println(updatedData)
        
        //if isCentralReady {
        

            
        characteristic.value = data
           let didSendValue = peripheralManager.updateValue(data, forCharacteristic: trackingCharacteristic, onSubscribedCentrals: nil)
           println("Bytes: \(data.length)")
           println("Sent?: \(didSendValue)")
           println(characteristic.value)

        //  }
   
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        println("Ready!")
        isCentralReady = true

        
        testConnection()
    }
    
    

}

