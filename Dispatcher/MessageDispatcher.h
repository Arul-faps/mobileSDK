//
//  MessageDispatcher.h
//  Created by Gal Blank on 9/21/15.
//  Copyright © 2015 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MessageDispatcher : NSObject
{
    NSTimer *dispsatchTimer;
    NSMutableArray * messageBus;
    
    NSMutableArray * dispatchedMessages;
    NSMutableArray *queueCallbacks;
}

+ (MessageDispatcher*) sharedInstance;

-(void)addMessageToBus:(Message*)newmessage;
-(void)startDispatching;
-(void)stopDispathing;

@end
