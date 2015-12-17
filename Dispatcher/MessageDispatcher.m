//
//  MessageDispatcher.m
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MessageDispatcher.h"
#import <pos-Swift.h>
#import "POS-Bridging-Header.h"
#import "CommManager.h"

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
            // ---------------------
            // ON HOLD ORDERS
            // ---------------------
        case messageTypeOnHoldOrdersSyncBatch:
            return @"messageTypeOnHoldOrdersSyncBatch";
            break;
        case messageTypeOnHoldOrdersSyncSingle:
            return @"messageTypeOnHoldOrdersSyncSingle";
            break;
            // ---------------------
            // ON HOLD ORDERS ACTIONS
            // ---------------------
        case messageTypeOnHoldOrdersActionPost:
            return @"messageTypeOnHoldOrdersActionPost";
            break;
        case messageTypeOnHoldOrdersActionDelete:
            return @"messageTypeOnHoldOrdersActionDelete";
            break;
        case messageTypeOnHoldOrdersActionGet:
            return @"messageTypeOnHoldOrdersActionGet";
            break;
            // ---------------------
            // PORTAL
            // ---------------------
        case messageTypeGotoPortal:
            return @"messageTypeGotoPortal";
            break;
        case messageTypeComebackFromPortal:
            return @"messageTypeComebackFromPortal";
            break;
        case messageTypeAskToUpdateFirmware:
            return @"messageTypeAskToUpdateFirmware";
            break;
        case messageTypeStartUpdatingFirmware:
            return @"messageTypeStartUpdatingFirmware";
            break;
        default:
            break;
    }
    
    return retMessage;
}

-(void)dispatchMessage:(Message*)message
{
    NSMutableDictionary * messageDic = [[NSMutableDictionary alloc] init];
    

    switch (message.mesRoute) {
        case MessageRouteMessageApiDelete:
        case MessageRouteMessageApiGet:
        case MessageRouteMessageApiPost:
        case MessageRouteMessageApiPut:
            message.messageApiEndPoint = [MessageApiConverter.sharedInstance messageTypeToApiCall:message.mesType];

            break;
        case MessageRouteMessageApiBatchPost:
        case MessageRouteMessageApiBatchGet:
            message.messageApiEndPoint = @"https://secure-qa.goemerchant.com/secure/mobilepos/v99/ios/mobilepos.ashx";
            
            break;
        default:
            break;
    }
    
    switch (message.mesRoute) {
        case MessageRouteMessageApiBatchPost:
        case MessageRouteMessageApiBatchGet:
            [self routeMessageToServerWithType:message];
     
            break;
        default:
            
            [messageDic setObject:message forKey:@"message"];
            [[NSNotificationCenter defaultCenter] postNotificationName:[self messageTypeToString:message.mesType] object:nil userInfo:messageDic];
            [dispatchedMessages addObject:message];
            break;
    }
    
    // GOS: Temporarily commented  out below in order handle internal routing of a batch request for On Hold Order message type.
    // It appears that message type below would prevent it from posting a batch request to the Comm Manager
    
//    [messageDic setObject:message forKey:@"message"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:[self messageTypeToString:message.mesType] object:nil userInfo:messageDic];
//    [dispatchedMessages addObject:message];
}


-(void)routeMessageToServerWithType:(Message*)message
{
    if(message.params == nil){
        message.params = [[NSMutableDictionary alloc] init];
    }
    
    NSString * sectoken = [[NSUserDefaults standardUserDefaults] objectForKey:@"securitytoken"];
    
    switch (message.mesType) {
        case messageTypeMESSAGETYPE_GET_CONFIG:
            
            break;
        case messageTypeTokenForTransactionRequest:
            

            
            if(sectoken && sectoken.length > 0){
                [message.params setObject:sectoken forKey:@"securitytoken"];
            }
            //[[CommManager sharedInstance] postAPI:@"Transaction/GenerateTokenForTransaction" andParams:@{@"merchantKey":[Config sharedInstance].gateway_id ,@"processorId":[AppConfiguration sharedConfig].midTidID}.mutableCopy];
            break;
        
        case messageTypeOnHoldOrdersSyncBatch:
            [[CommManager sharedInstance] batchPostAPI:message.messageApiEndPoint andParams:message.params];
            break;
            
        default:
            break;
    }
}




-(BOOL)canSendMessage:(Message*)message
{
    switch (message.mesType) {
        case messageTypeMESSAGETYPE_GET_CONFIG:
        case messageTypeTokenForTransactionRequest:
        break;
        default:
            break;
    }
    
    return YES;
}


@end
