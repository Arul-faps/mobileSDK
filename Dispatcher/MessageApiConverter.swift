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



    func messageTypeToString(Type: MessageRoute) -> String {
        var retMessage: String = ""
        
        switch (Type) {
        case .MESSAGE_API_GET:
            break
            

        case .MESSAGE_API_POST:
            break

        case .MESSAGE_API_DELETE:
            break

        case .MESSAGE_API_PUT:
            break
            
        default:
            break

    }
        return retMessage
    }
 
    
}