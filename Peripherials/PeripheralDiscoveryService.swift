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
    
    var entitledHardware: NSDictionary?
    
    override init() {
        super.init()
        
        if let path = NSBundle.mainBundle().pathForResource("HardwareEntitlements", ofType: "plist") {
            entitledHardware = NSDictionary(contentsOfFile: path)
            NSLog("%@", entitledHardware!)
        }
        
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
        NSLog("Recevied %@ for %@",notif.name,accessory)
    }
    
    func findAssignedPrintersForSlipType(slipType:String) -> Bool
    {
        if(slipType.caseInsensitiveCompare(RECEIPT_PRINTERS) == NSComparisonResult.OrderedSame && AppConfiguration.sharedConfig().powaTSeriesMgr.isPrinterReady() == true){
            return true
        }
        var query: String = "SELECT * FROM network_printers where assigned_db_id != 0"
        let index:Int32 = DBManager.sharedInstance().loadDataFromDB(query)
        while DBManager.sharedInstance().hasDataForIndex(index) {
            let row: [NSObject : AnyObject] = DBManager.sharedInstance().nextForIndex(index) as [NSObject : AnyObject]
            let assigned_db_id  = (row["assigned_db_id"] as! NSString)
            query = "SELECT * FROM printers WHERE id = \(assigned_db_id)"
            let insideindex:Int32 = DBManager.sharedInstance().loadDataFromDB(query)
            while DBManager.sharedInstance().hasDataForIndex(insideindex) {
                var row: [NSObject : AnyObject] = DBManager.sharedInstance().nextForIndex(insideindex) as [NSObject : AnyObject]
                let printer_type = (row["printer_type"] as! String)
                if(printer_type.caseInsensitiveCompare(slipType) == NSComparisonResult.OrderedSame){
                    return true
                }
            }
        }
        
        return false
    }
    
    func consumeMessage(notif:NSNotification)
    {
        let msg = notif.userInfo!["message"] as! Message
        switch (msg.routingKey){
        case "internal.searchForPeripherals":
            self.searchForConnectedAccessories()
            break;
        case "internal.checkforavailabledevice":
            
            let peripheralType = msg.params.objectForKey("peripheralType") as! String
            let manual: NSNumber = msg.params.objectForKey("ismanualprinting") as! NSNumber
            let isExistingReceiptPrinterAvailable: Bool = self.findAssignedPrintersForSlipType(peripheralType)

            let msg:Message = Message()
            if(isExistingReceiptPrinterAvailable == true || AppConfiguration.sharedConfig().powaTSeriesMgr.isPrinterReady() == true){
                msg.routingKey = "internal.deviceisavailable"
            }
            else{
                msg.routingKey = "internal.deviceisnotavailable"
            }
            msg.params = ["peripheralType" : peripheralType,"ismanualprinting":manual]
            MessageDispatcher.sharedInstance().addMessageToBus(msg)
            break;
        default:
            break;
        }
    }
    
    
    func searchForConnectedAccessories() -> [AnyObject] {
        connectedAccessories = EAAccessoryManager.sharedAccessoryManager().connectedAccessories
        NSLog("Detected Devices %@", connectedAccessories)
        return connectedAccessories
    }
}
