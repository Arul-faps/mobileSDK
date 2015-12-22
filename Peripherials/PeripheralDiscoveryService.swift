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
    
    var printersList = [AnyObject]()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name:"internal.searchForPeripherals", object: nil)
    }
    
    func consumeMessage(notif:NSNotification)
    {
        let msg = notif.userInfo!["message"] as! Message
        switch (msg.routingKey){
        case "internal.searchForPeripherals":
            let peripheralType = msg.params.objectForKey("peripheralType")
            if(peripheralType?.caseInsensitiveCompare(PRINTERS) == NSComparisonResult.OrderedSame){
                self.searchForAllConnectedPrinters()
            }
            else if(peripheralType?.caseInsensitiveCompare(SCANNERS) == NSComparisonResult.OrderedSame){
                self.searchForAllConnectedPrinters()
            }
            break;
        default:
            break;
        }
    }
    
    
    func connectedPrinters() -> [AnyObject] {
        printersList = EAAccessoryManager.sharedAccessoryManager().connectedAccessories
        NSLog("Detected Devices %@", printersList)
        return printersList
    }
    
    func searchForAllConnectedPrinters() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            self.printersList = SMPort.searchPrinter()
            NSLog("Found printers %@", self.printersList)
            var savedPrinters:AnyObject = ["":""]
            if(NSUserDefaults.standardUserDefaults().objectForKey("printers")?.count > 0){
                savedPrinters = NSUserDefaults.standardUserDefaults().objectForKey("printers")!
            }
            savedPrinters.setObject(self.printersList, forKey: AppConfiguration.sharedConfig().midTidID)
            NSUserDefaults.standardUserDefaults().setObject(savedPrinters, forKey: "printers")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}
