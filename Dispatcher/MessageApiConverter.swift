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
        default:
            break

    }
        msg.routingKey = "api.*"
    }
    
    
}