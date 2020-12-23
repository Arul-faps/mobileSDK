//
//  MessageApiConverter.m
//  POS
//
//  Created by Gal Blank on 11/30/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import Foundation

class MessageApiConverter:NSObject  {
    
    static let sharedInstance = MessageApiConverter()
    
    func messageTypeToApiCall(_ msg:Message) {
        
        switch (msg.messageFromRoutingKey()) {
        case "messageTypeTokenForTransaction":
            msg.messageApiEndPoint = "Transaction/GenerateTokenForTransaction"
            msg.httpMethod = "get";
            break
        case "messageTypeOnHoldOrdersBatchPost":
            
            msg.messageApiEndPoint = ""
            msg.httpMethod = "batchPost";
            break
        case "messageTypeOnHoldOrdersSinglePost":
            
            msg.messageApiEndPoint = ""
            msg.httpMethod = "post";
            break
        case "messageTypeOnHoldOrdersRetrieveCompacted":
            
            msg.messageApiEndPoint = ""
            msg.httpMethod = "get";
            break
        default:
            
            msg.messageApiEndPoint = ""
            msg.httpMethod = "post";
            break
        }
        msg.routingKey = "api.*"
    }
}
