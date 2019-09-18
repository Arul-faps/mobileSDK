//
//  Message.swift
//  POS
//
//  Created by Gal Blank on 1/27/16.
//  Copyright © 2016 1stPayGateway. All rights reserved.
//

import UIKit

 class Message:NSObject {
    @objc var routingKey:String = String("")
    var httpMethod:String = String("")
   @objc var params:AnyObject?
    var ttl:Float = 0.1
    var shouldselfdestruct:Bool = false
    var messageApiEndPoint:String = String("")
    
   @objc init(routKey:String) {
        super.init()
        self.routingKey = routKey
    }
    
    func routeFromRoutingKey() -> String {
        let keyitems:[AnyObject]? = self.routingKey.components(separatedBy: ".") as [AnyObject]
        if keyitems != nil {
			return keyitems![0] as! String
        }
        return ""
    }
    
    func messageFromRoutingKey() -> String {
        let keyitems:[AnyObject]? = self.routingKey.components(separatedBy: ".") as [AnyObject]
        if keyitems != nil {
			return (keyitems?.last)! as! String
        }
        return ""
    }
    
     @objc func selfDestruct()
    {
        routingKey = "msg.selfdestruct"
        MessageDispatcher.sharedDispacherInstance.addMessageToBus(newmessage: self)
    }
}
