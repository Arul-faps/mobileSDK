//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import UIKit

class PolymorphicPrinterService: NSObject {

    var printersList = [AnyObject]()

    func startService(){}
    
    func consumeMessage(notif:NSNotification){}
    
    func printerDidConnect(notif:NSNotification){}
    
    func connectedPrinters() -> [AnyObject] {
        printersList = EAAccessoryManager.sharedAccessoryManager().connectedAccessories
        NSLog("Detected Devices %@", printersList)
        return printersList
    }
    
    func searchForPrinters() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
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
