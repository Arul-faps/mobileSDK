//
//  Message.swift
//  POS
//
//  Created by Gal Blank on 1/27/16.
//  Copyright © 2016 1stPayGateway. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    @objc var routingKey:String = String("")
    @objc var httpMethod:String = String("")
    @objc var params:AnyObject?
    @objc var ttl:Float = 0.1
    @objc var shouldselfdestruct:Bool = false
    @objc var messageApiEndPoint:String = String("")
    
    @objc init(routKey:String) {
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
    
    @objc func selfDestruct() {
        
        routingKey = "msg.selfdestruct"
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(self)
    }
}
