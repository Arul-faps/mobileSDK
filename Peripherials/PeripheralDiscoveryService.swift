//
//  PeripheralDiscoveryService.swift
//  POS
//
//  Created by Gal Blank on 12/18/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import UIKit

class PeripheralDiscoveryService: NSObject {
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "consumeMessage:", name:"internal.searchForPeripherals", object: nil)
    }
    
    func consumeMessage(notif:NSNotification)
    {
        let msg = notif.userInfo!["message"] as! Message
        switch (msg.routingKey){
        case "internal.searchForPeripherals":
            
            break;
        default:
            break;
        }
    }
    
    
}
