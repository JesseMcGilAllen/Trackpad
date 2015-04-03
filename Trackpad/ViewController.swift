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
    var eventCharacteristic : CBMutableCharacteristic!
    var scrollingCharacteristic : CBMutableCharacteristic!
    
    var buttons : Array<UILabel>!
    
    
    @IBOutlet weak var leftClick: UILabel!
    @IBOutlet weak var rightClick: UILabel!
    @IBOutlet weak var doubleClick: UILabel!
    @IBOutlet weak var scrolling: UILabel!
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        buttons = [leftClick, rightClick, doubleClick, scrolling]
        
        configureButtons(buttons)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureButtons(buttons : Array<UILabel>) {
        
        for button in buttons {
            
            configureButtonStateDefault(button)
            
        }
        
    }
    
    func configureButtonStateDefault(button : UILabel) {
        
        button.layer.borderColor = UIColor.blueColor().CGColor
        button.layer.backgroundColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 1.0
        
        button.textColor = UIColor.blueColor()
        button.layer.cornerRadius = button.frame.size.height / 4
    }
    
    func configureButtonStateSelected(button : UILabel) {
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.backgroundColor = UIColor.blueColor().CGColor
        button.layer.borderWidth = 1.0
        
        button.textColor = UIColor.whiteColor()
        button.layer.cornerRadius = button.frame.size.height / 4
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
    
    func trackpadService() -> CBMutableService {
        
        
        var trackpadService = CBMutableService(type: trackpadServiceUUID(), primary: true)
        trackingCharacteristic = characteristicWithUUID(trackingCharacteristicUUID())
        beginTrackingCharacteristic = characteristicWithUUID(beginTrackingCharacteristicUUID())
        eventCharacteristic = characteristicWithUUID(eventCharacteristicUUID())
        scrollingCharacteristic = characteristicWithUUID(scrollingCharacteristicUUID())
        trackpadService.characteristics = [beginTrackingCharacteristic,
                                           trackingCharacteristic,
                                           eventCharacteristic,
                                           scrollingCharacteristic]
        
        return trackpadService
    }
    
    func characteristicWithUUID(uuid : CBUUID) -> CBMutableCharacteristic {
        
        return CBMutableCharacteristic(type: uuid,
            properties: CBCharacteristicProperties.Read | CBCharacteristicProperties.NotifyEncryptionRequired,
            value: nil,
            permissions: CBAttributePermissions.ReadEncryptionRequired)
    }
    
    // MARK: CBUUID creation
    
    func trackpadServiceUUID() -> CBUUID {
        return CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    }
    
    func beginTrackingCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "E0A13890-5CAB-4763-863C-B639132CE144")
    }
    
    
    
    func trackingCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
    }
    
    
    func eventCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "DCF9D966-06D7-4663-8811-3E1A0B75EFB4")
    }
    
    func scrollingCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "F2021764-206F-46D5-8AD9-F710A484FAEC")
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
    
    func sendButtonClick(title : String) {
        
        
        let data = title.dataUsingEncoding(NSUTF8StringEncoding)
        
        let didSendValue = peripheralManager.updateValue(data, forCharacteristic: eventCharacteristic, onSubscribedCentrals: nil)

    }
    
   
    @IBAction func tapDetected(sender: UITapGestureRecognizer) {
        
        let location = sender.locationInView(self.view)
        
        for button in buttons {
            
            if CGRectContainsPoint(button.frame, location) {
            
                // if scrolling button that got tapped send to the processScrolling func
                // else go to sendButtonClick func
                button == scrolling ? processScrolling() : sendButtonClick(button.text!)
                
            }
        }
    }
    
    
    // flips text to begin/end scrolling depending on current text
    // changes button color depending on text
    func processScrolling() {
        
        let label = scrolling.text
        let selectedLabel = "end scrolling"
        let defaultLabel = "begin scrolling"
        
        if label == defaultLabel {
            
            configureButtonStateSelected(scrolling)
            scrolling.text = selectedLabel
            
        } else {
            
            configureButtonStateDefault(scrolling)
            scrolling.text = defaultLabel
            
        }
        
    }
    
    func scrollingEnabled() -> Bool {
        
        let label = scrolling.text
        let defaultLabel = "begin scrolling"
        if label == defaultLabel {
            
            return false
        
        } else {
            
            return true
        }
    }
    
    
}



