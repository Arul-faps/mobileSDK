//
//  CommMamanger.m
//  Created by Gal Blank on 5/21/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import "CommManager.h"
#import "StringHelper.h"
#import "AppDelegate.h"
#import "MessageDispatcher.h"

@implementation CommManager


static CommManager *sharedSampleSingletonDelegate = nil;

@synthesize imagesDownloadQueue;


+ (CommManager *)sharedInstance {
    @synchronized(self) {
        if (sharedSampleSingletonDelegate == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedSampleSingletonDelegate;
}



+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSampleSingletonDelegate == nil) {
            sharedSampleSingletonDelegate = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedSampleSingletonDelegate;
        }
    }
    // on subsequent allocation attempts return nil
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(id)init
{
    if (self = [super init]) {
       self.imagesDownloadQueue = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//message from dispatcher
-(void)consumeMessage:(NSNotification*)notification
{
    Message * msg = [notification.userInfo objectForKey:@"message"];
    NSLog(@"RBA:ConsumeMessage:%d",msg.mesType);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[[MessageDispatcher sharedInstance] messageTypeToString:msg.mesType] object:nil];
    
    switch (msg.mesType) {
        case IngenicoMessage:
        {

        }
            break;
            
        default:
            break;
    }
}

-(void)getAPI:(NSString*)api andParams:(NSMutableDictionary*)params{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString *fullAPI = [NSString stringWithFormat:@"%@%@",ROOT_API,api];
    NSLog(@"GET: %@<>%@",fullAPI,params);
    
    [manager GET:fullAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        Message *msg = [[Message alloc] init];
        msg.mesRoute = MessageRouteMessageInternal;
        msg.mesType = [[responseObject objectForKey:@"messageid"] intValue];
        msg.params = [responseObject objectForKey:@"data"];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)postAPI:(NSString*)api andParams:(NSMutableDictionary*)params{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString *fullAPI = [NSString stringWithFormat:@"%@%@",ROOT_API,api];

    
    [manager POST:fullAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        Message *msg = [[Message alloc] init];
        msg.mesRoute = MessageRouteMessageInternal;
        msg.ttl = TTL_NOW;
        msg.mesType = [[MessageDispatcher sharedInstance] messageNameTomessageType:[responseObject objectForKey:@"action"]];
        msg.params = [responseObject objectForKey:@"data"];
        [[MessageDispatcher sharedInstance] addMessageToBus:msg];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
