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

    func messageTypeToApiCall(msg:Message) {

        switch (msg.messageFromRoutingKey()) {
        case "messageTypeTokenForTransaction":
            msg.messageApiEndPoint = "Transaction/GenerateTokenForTransaction"
            msg.httpMethod = "get";
            break
        case "messageTypeOnHoldOrdersBatch":
            msg.messageApiEndPoint = "https://secure.1stpaygateway.net/secure/mobilepos/v99/ios/mobilepos.ashx"
            msg.httpMethod = "postBatch";
            break
        default:
            break

        }
        
        msg.routingKey = "api.*"
    }
    
    
}