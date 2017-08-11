//
//  Message.swift
//  POS
//
//  Created by Gal Blank on 1/27/16.
//  Copyright © 2016 1stPayGateway. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var routingKey:String = String("")
    var httpMethod:String = String("")
    var params:AnyObject?
    var ttl:Float = 0.1
    var shouldselfdestruct:Bool = false
    var messageApiEndPoint:String = String("")
    
    init(routKey:String) {
        super.init()
        self.routingKey = routKey
    }
    
    func routeFromRoutingKey() -> String {
        
        var keyitems:[String]? = self.routingKey.components(separatedBy: ".")
        
        if keyitems != nil {
            return keyitems![0] 
        }
        return ""
    }
    
    func messageFromRoutingKey() -> String {
        
        let keyitems:[String]? = self.routingKey.components(separatedBy: ".")
      
        if keyitems != nil {
            return (keyitems?.last)! 
        }
        return ""
    }
    
    func selfDestruct() {
        
        routingKey = "msg.selfdestruct"
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(self)
    }
}
