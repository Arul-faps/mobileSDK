//
//  Message.m
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize routingKey,params,ttl,messageApiEndPoint,httpMethod;

-(NSString*)routeFromRoutingKey
{
    NSMutableArray * keyitems = [self.routingKey componentsSeparatedByString:@"."].mutableCopy;
    if(keyitems){
        return keyitems[0];
    }
    return @"";
}

-(NSString*)messageFromRoutingKey
{
    NSMutableArray * keyitems = [self.routingKey componentsSeparatedByString:@"."].mutableCopy;
    if(keyitems){
        return [keyitems lastObject];
    }
    return @"";
}
@end
