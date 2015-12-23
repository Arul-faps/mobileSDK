//
//  Message.h
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_TTL 5.0
#define TTL_NOW 0.1;
#define CLEANUP_TIMER 10.0

#define PRINTERS @"printers"
#define SCANNERS @"scanners"
#define RECEIPT_PRINTERS @"RECEIPT_PRINTERS"
#define ITEMS_PRINTERS   @"ITEMS_PRINTERS"

@interface Message : NSObject

@property(nonatomic,strong)NSString *routingKey;
@property(nonatomic,strong)NSString *httpMethod;
@property(nonatomic,strong)id params;
@property(nonatomic)float ttl;
@property(nonatomic,strong)NSString *messageApiEndPoint;

-(NSString*)routeFromRoutingKey;
-(NSString*)messageFromRoutingKey;
@end
