//
//  PeripheralDiscoveryService.swift
//  POS
//
//  Created by Gal Blank on 12/18/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import UIKit

class PeripheralDiscoveryService: NSObject {
    
    static let sharedInstance = PeripheralDiscoveryService()
    
    var connectedAccessories = [AnyObject]()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name:"internal.searchForPeripherals", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name:"internal.checkforavailabledevice", object: nil)
        EAAccessoryManager.sharedAccessoryManager().registerForLocalNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "externalAccessoryNotification:", name:EAAccessoryDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "externalAccessoryNotification:", name:EAAccessoryDidDisconnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "externalAccessoryNotification:", name:EAAccessoryKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "externalAccessoryNotification:", name:EAAccessorySelectedKey, object: nil)
    }
    
    func externalAccessoryNotification(notif:NSNotification)
    {
        switch(notif.name){
        case EAAccessoryDidConnectNotification:
            break
        case EAAccessoryDidDisconnectNotification:
            break;
        case EAAccessoryKey:
            break
        case EAAccessorySelectedKey:
            break
        default:
            break
        }
        let accessory:EAAccessory = notif.userInfo!["EAAccessoryKey"] as! EAAccessory
        NSLog("Recevied %@ for %@",notif.name,accessory.description)
    }
    
    func consumeMessage(notif:NSNotification)
    {
        let msg = notif.userInfo!["message"] as! Message
        switch (msg.routingKey){
        case "internal.searchForPeripherals":
            self.searchForConnectedAccessories()
            break;
        case "internal.checkforavailabledevice":
            var isExistingReceiptPrinterAvailable: Bool = false
            
            let peripheralType = msg.params!.objectForKey("peripheralType") as! String
            if(peripheralType.caseInsensitiveCompare("receipt") == NSComparisonResult.OrderedSame){
                let manual: NSNumber = msg.params!.objectForKey("ismanualprinting") as! NSNumber
                var printers: [NSObject : AnyObject] = NSUserDefaults.standardUserDefaults().objectForKey("printers") as! [NSObject : AnyObject]
                let existingPrinters = printers[AppConfiguration.sharedConfig().midTidID] as! [AnyObject]
                NSLog("internal.checkforavailabledevice: ", existingPrinters);
                for oneprinter in existingPrinters {
                    if (oneprinter.objectForKey("printer_type")?.caseInsensitiveCompare("receipt") == NSComparisonResult.OrderedSame) {
                        isExistingReceiptPrinterAvailable = true
                        break;
                    }
                }
                
                let msg:Message
                if(isExistingReceiptPrinterAvailable == true || AppConfiguration.sharedConfig().powaTSeriesMgr.isPrinterReady() == true){
                    msg = Message(routKey: "internal.deviceisavailable")
                }
                else{
                    msg = Message(routKey: "internal.deviceisnotavailable")
                }
                msg.params = ["peripheralType" : peripheralType,"ismanualprinting":manual]
                MessageDispatcher.sharedDispacherInstance.addMessageToBus(msg)
            }
            else if(peripheralType.caseInsensitiveCompare("items") == NSComparisonResult.OrderedSame){
                
            }
            break;
        default:
            break;
        }
        msg.selfDestruct()
    }
    
    
    func searchForConnectedAccessories() -> [AnyObject] {
        connectedAccessories = EAAccessoryManager.sharedAccessoryManager().connectedAccessories
        NSLog("Detected Devices %@", connectedAccessories)
        return connectedAccessories
    }
}