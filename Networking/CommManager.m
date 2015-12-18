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
    NSLog(@"Running CommManager init....");
    if (self = [super init]) {
       self.imagesDownloadQueue = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consumeMessage:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MessageRouteMessageApiDelete] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consumeMessage:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MessageRouteMessageApiGet] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consumeMessage:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MessageRouteMessageApiPost] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consumeMessage:) name:[[MessageDispatcher sharedInstance] messageTypeToString:MessageRouteMessageApiPut] object:nil];
    }
    return self;
}

//message from dispatcher
-(void)consumeMessage:(NSNotification*)notification
{
    Message * msg = [notification.userInfo objectForKey:@"message"];
    
    switch (msg.mesRoute) {
        case MessageRouteMessageApiGet:
        {
            [self getAPI:msg.messageApiEndPoint andParams:msg.params];
        }
            break;
        case MessageRouteMessageApiPost:
        {
            [self postAPI:msg.messageApiEndPoint andParams:msg.params];
        }
            break;
        case MessageRouteMessageApiBatchPost:
        {
            [self batchPostAPI:msg.messageApiEndPoint andParams:msg.params];
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


/**
    Handle Batch POSTs
 
  - Parameter api:   The API endpoint.
  - Parameter params:   The message parameter list.
 */
-(void)batchPostAPI:(NSString*)api andParams:(NSArray*)paramsList {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    

    NSArray *requestOperations = [CommManager buildRequestOperationsForApi:api withParamsList:paramsList];

    
    if (requestOperations.count>0) {
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestOperations
                                                                   progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                                                       NSLog(@"%lu of %lu Completed", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
                                                                   } completionBlock:^(NSArray *operations) {
                                                                       NSLog(@"Completion: %@", operations);
                                                                       
                                                                       NSMutableArray *responseList =[NSMutableArray new];
                                                                       
                                                                       // Build an array of the response dictionaries
                                                                       [operations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                           AFHTTPRequestOperation *afReqObject = (AFHTTPRequestOperation *)obj;
                                                                           
                                                                           NSData *responseObject = (NSData *)[afReqObject responseObject];
                                                                           NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                                                           NSLog(@"responseObject[data]: %@", responseDict[@"data"]);
                                                                           
                                                                           NSLog(@"Operation: %@", [afReqObject responseString]);
                                                                           
                                                                           [responseList addObject:responseDict[@"data"]];

                                                                       }];
                                                                       
                                                                       // Send Array of response dictionaries on message bus
                                                                       if ([responseList count] > 0) {
                                                                           Message *msg = [[Message alloc] init];
                                                                           msg.mesRoute = MessageRouteMessageInternal;
                                                                           msg.ttl = TTL_NOW;
                                                                           msg.mesType = [[MessageDispatcher sharedInstance] messageNameTomessageType:@"OnHoldOrderMessage"];
                                                                           msg.params = [responseList copy]; // make it immutable
                                                                           [[MessageDispatcher sharedInstance] addMessageToBus:msg];
                                                                       }

                                                                       
                                                                       

                                                                       
                                                                   }];
        
        [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    }

}

/**
    Build a set of request operations for AFNetworking.
    Need to format these request as form data (not JSON) since implementing the older WS model.
    NOTE: When new API implemented, use JSON.
 
 - Parameter api:   The API endpoint.
 - Parameter params:   The message parameter list.
 */
+ (NSArray*)buildRequestOperationsForApi:(NSString*)api withParamsList:(NSArray*)paramsList
{
    NSMutableArray *mutableOperations = [NSMutableArray new];
    NSString *fullAPI = api;
    
    for (NSDictionary *params in paramsList) {
        
        // FORM DATA AF REQUEST
        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:fullAPI parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
                NSLog(@"key: %@", key);
                NSLog(@"value: %@", [obj dataUsingEncoding:NSUTF8StringEncoding]);
                [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding] name:key];
            }];
           
        } error:nil];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [mutableOperations addObject:operation];
    }
    
    
    return [mutableOperations copy];
}


@end
