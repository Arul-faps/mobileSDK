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
        [self dispatchMessage:newmessage];
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
    NSArray * goingAwayBus = [NSArray arrayWithArray:messageBus];
    for(Message *msg in goingAwayBus){
        [self dispatchMessage:msg];
    }
}


<<<<<<< HEAD
-(messageType)messageNameTomessageType:(NSString*)messageName
{
    if([messageName caseInsensitiveCompare:@"TokenForTransaction"] == NSOrderedSame){
        return messageTypeTokenForTransaction;
    }
    else if([messageName caseInsensitiveCompare:@"IngenicoMessage"] == NSOrderedSame){
        return messageTypeIngenicoMessage;
    }
    else if([messageName caseInsensitiveCompare:@"OnHoldOrderMessage"] == NSOrderedSame){
        return messageTypeIngenicoMessage;
    }
    
    return -1;
}

-(NSString*)messageTypeToString:(messageType)Type
{
    NSString *retMessage = @"";
    switch (Type) {
        case messageTypeMESSAGETYPE_GET_CONFIG:
            retMessage = @"MESSAGETYPE_GET_CONFIG";
            break;
        case messageTypeTokenForTransactionRequest:
            retMessage = @"TokenForTransactionRequest";
            break;
        case messageTypeTokenForTransaction:
            retMessage = @"TokenForTransaction";
            break;
        case messageTypeIngenicoMessage:
            retMessage = @"IngenicoMessage";
            break;
        case messageTypeUserInitializeHardware:
            return @"messageTypeUserInitializeHardware";
            break;
        case messageTypeStartScanners:
            return @"messageTypeStartScanners";
            break;
        case messageTypeStopScanners:
            return @"messageTypeStopScanners";
            break;
        case messageTypeProductScanned:
            return @"messageTypeProductScanned";
            break;
        case messageTypeOnHoldOrdersBatchSync:
            return @"messageTypeOnHoldOrdersBatchedSync";
            break;
        case messageTypeOnHoldOrderSync:
            return @"messageTypeOnHoldOrderSync";
        case messageTypeGotoPortal:
            return @"messageTypeGotoPortal";
            break;
        case messageTypeComebackFromPortal:
            return @"messageTypeComebackFromPortal";

            break;
        default:
            break;
    }
    
    return retMessage;
}
=======
>>>>>>> a48ee7ba9c2880518082747d8c1aacba9abdbe8e

-(void)dispatchMessage:(Message*)message
{
    NSMutableDictionary * messageDic = [[NSMutableDictionary alloc] init];
    
    if([[message routeFromRoutingKey] caseInsensitiveCompare:@"api"] == NSOrderedSame){
        [MessageApiConverter.sharedInstance messageTypeToApiCall:message];
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
