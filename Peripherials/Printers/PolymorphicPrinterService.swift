//
//  PolymorphicScannerService.swift
//  POS
//
//  Created by Gal Blank on 12/15/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import UIKit

class PolymorphicPrinterService: NSObject {

    var printersList = [EAAccessory]()
    

    
    func startService(){}
    
    func consumeMessage(notif:NSNotification){}
    
    func printerDidConnect(notif:NSNotification){}
    
    func detectPrinters() -> [EAAccessory] {
        printersList = EAAccessoryManager.sharedAccessoryManager().connectedAccessories
        NSLog("Detected Devices %@", printersList)
        return printersList
    }
}
