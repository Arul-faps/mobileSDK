//
//  MessageDispatcher.m
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MessageDispatcher.h"
#import <pos-Swift.h>
#import "POS-Bridging-Header.h"
#import "RegexKitLite.h"

@implementation MessageDispatcher

static MessageDispatcher *sharedDispatcherInstance = nil;


+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedDispatcherInstance == nil) {
            sharedDispatcherInstance = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedDispatcherInstance;
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
        if(messageBus == nil){
            messageBus = [[NSMutableArray alloc] init];
        }
        
        if(dispatchedMessages == nil){
            dispatchedMessages = [[NSMutableArray alloc] init];
        }
        
        
             [NSTimer scheduledTimerWithTimeInterval:CLEANUP_TIMER target:self selector:@selector(clearDispastchedMessages) userInfo:nil repeats:YES];
        
       
    }
    return self;
}

-(void)addMessageToBus:(Message*)newmessage
{

    if(newmessage.ttl == DEFAULT_TTL){
        [messageBus addObject:newmessage];
        if(dispsatchTimer == nil){
            [self startDispatching];
        }
    }
    else{
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:newmessage forKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSTimer scheduledTimerWithTimeInterval:newmessage.ttl target:self selector:@selector(dispatchThisMessage:) userInfo:userInfo repeats:NO];
        });
    }
}


-(void)clearDispastchedMessages
{
    for (Message *msg in dispatchedMessages) {
        [messageBus removeObject:msg];
    }
    [dispatchedMessages removeAllObjects];
}

-(void)dispatchThisMessage:(NSTimer*)timer
{
    Message* message = [timer.userInfo objectForKey:@"message"];
    if(message){
        [self dispatchMessage:message];
    }
}

-(void)startDispatching
{
    dispsatchTimer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_TTL target:self selector:@selector(leave) userInfo:nil repeats:YES];
}

-(void)stopDispathing
{
    if(dispsatchTimer){
        [dispsatchTimer invalidate];
        dispsatchTimer = nil;
    }
}

-(void)leave
{
    for(Message *msg in messageBus){
        [self dispatchMessage:msg];
    }
}



-(void)dispatchMessage:(Message*)message
{
    NSMutableDictionary * messageDic = [[NSMutableDictionary alloc] init];
    

    if([[message routeFromRoutingKey] caseInsensitiveCompare:@"api"] == NSOrderedSame){
        message.messageApiEndPoint = [MessageApiConverter.sharedInstance messageTypeToApiCall:message.routingKey];
    }
    
    [messageDic setObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:message.routingKey object:nil userInfo:messageDic];
    [dispatchedMessages addObject:message];
}


-(void)routeMessageToServerWithType:(Message*)message
{
    if(message.params == nil){
        message.params = [[NSMutableDictionary alloc] init];
    }
    
    NSString * sectoken = [[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"];
    
    if(sectoken && sectoken.length > 0){
        [message.params setObject:sectoken forKey:@"securitytoken"];
    }
}




-(BOOL)canSendMessage:(Message*)message
{
    return YES;
}


@end
