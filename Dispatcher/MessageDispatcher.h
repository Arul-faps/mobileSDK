//
//  MessageDispatcher.h
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import <UIKit/UIKit.h>
@interface MessageDispatcher : NSObject
{
    NSTimer *dispsatchTimer;
    NSMutableArray * messageBus;
    
    NSMutableArray * dispatchedMessages;
    
    void (^uploadFinishedBlock)(NSString*imageID);
    NSMutableArray *queueCallbacks;
}

+ (MessageDispatcher*) sharedInstance;

-(void)addMessageToBus:(Message*)newmessage;
-(void)startDispatching;
-(void)stopDispathing;
-(NSString*)messageTypeToString:(messageType)Type;
-(messageType)messageNameTomessageType:(NSString*)messageName;

@end
