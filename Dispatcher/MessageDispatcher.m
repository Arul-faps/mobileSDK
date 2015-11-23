//
//  MessageDispatcher.m
//  missingkids
//
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import "MessageDispatcher.h"

@implementation MessageDispatcher

MessageDispatcher *sharedInstance = nil;


+ (MessageDispatcher*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
            
        }
    }
    
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedInstance;
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
        NSTimer * scheduled = [NSTimer scheduledTimerWithTimeInterval:newmessage.ttl target:self selector:@selector(dispatchThisMessage:) userInfo:userInfo repeats:NO];
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


-(NSString*)messageTypeToString:(messageType)Type
{
    NSString *retMessage = @"";
    switch (Type) {
        case MESSAGETYPE_GET_CONFIG:
            retMessage = @"MESSAGETYPE_GET_CONFIG";
            break;
        
        default:
            break;
    }
    
    return retMessage;
}

-(void)dispatchMessage:(Message*)message
{
    switch (message.mesRoute) {
        case MESSAGEROUTE_API:
            if([self canSendMessage:message]){
               [self routeMessageToServerWithType:message];
            }
            [dispatchedMessages addObject:message];
            break;
        case MESSAGEROUTE_INTERNAL:
        {
            NSMutableDictionary * messageDic = [[NSMutableDictionary alloc] init];
            [messageDic setObject:message forKey:@"message"];
            [[NSNotificationCenter defaultCenter] postNotificationName:[self messageTypeToString:message.mesType] object:nil userInfo:messageDic];
            [dispatchedMessages addObject:message];
        }
            break;
        case MESSAGEROUTE_OTHER:
            break;
        default:
            break;
    }
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
    
    switch (message.mesType) {
        case MESSAGETYPE_GET_CONFIG:
            //[[CommManager sharedInstance] postAPI:@"NewUser" andParams:message.params];
            break;
        default:
            break;
    }
}



-(NSString*)generatelocalpathforImageID:(NSString*)imageID
{
    if(imageID == nil){
        imageID = [NSString stringWithFormat:@"%f.jpg",[[NSDate date] timeIntervalSince1970]];
    }
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentURL = [paths objectAtIndex:0];
    documentURL = [documentURL URLByAppendingPathComponent:@"missingkids_images" isDirectory:YES];
    BOOL bExists = NO;
    BOOL isFolder;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[documentURL path] isDirectory:&isFolder])
    {
        NSError *error = nil;
        bExists = [[NSFileManager defaultManager] createDirectoryAtURL:documentURL withIntermediateDirectories:YES attributes:nil error:&error];
    }
    else{
        bExists = YES;
    }
    NSString * url = [NSString stringWithFormat:@"%@/%@",documentURL.path,imageID];
    return url;
}



-(NSString *)saveImage:(UIImage*)image{
    NSString * localpath  = [self generatelocalpathforImageID:nil];
    BOOL bFileWritten = [UIImageJPEGRepresentation(image, 0.0) writeToFile:localpath atomically:YES];
    return localpath;
}




-(BOOL)canSendMessage:(Message*)message
{
    switch (message.mesType) {
        case MESSAGETYPE_GET_CONFIG:
        {
            if(((NSString*)([message.params objectForKey:@"apnskey"])).length <= 10){
                return NO;
            }
            
            
        }
        break;
        default:
            break;
    }
    
    return YES;
}


@end
