//
//  MessageApiConverter.m
//  POS
//
//  Created by Gal Blank on 11/30/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

#import "MessageApiConverter.h"



@implementation MessageApiConverter

static  MessageApiConverter *sharedApiConverterInstance = nil;

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
        if (sharedApiConverterInstance == nil) {
            sharedApiConverterInstance = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedApiConverterInstance;
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
    
    }
    return self;
}




@end
