//
//  Message.h
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Message : NSObject

@property(nonatomic,strong)NSString *routingKey;
@property(nonatomic,strong)NSString *httpMethod;
@property(nonatomic,strong)id params;
@property(nonatomic)float ttl;
@property(nonatomic,strong)NSString *messageApiEndPoint;

-(NSString*)routeFromRoutingKey;
-(NSString*)messageFromRoutingKey;
@end
