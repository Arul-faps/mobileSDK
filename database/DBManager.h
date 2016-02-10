//
//  DBManager.h
//  GoEmerchant.com
//
//  Created by Gal Blank on 12/19/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>





#define LOCAL_DB_FILE_NAME     @"database"
#define LOCAL_DB_FILE_EXT      @"sqlite"
#define DB_BUNDLE_VERSION_KEY  @"kDB_BUNDLE_VERSION_KEY"
#define DB_QUEUE_NAME          "com.goe.app.dbqueue"


@interface DBManager : NSObject
{
    NSString *databaseFullPath;
    int affectedRows;
    NSString *documentsDirectory;
    
    NSMutableDictionary * arraysmatrix;
    NSMutableDictionary * currentIndexMatrix;
    dispatch_queue_t databaseQueue;
    
    int currentMatrixIndex;
}

@property(nonatomic)long long lastInsertedRowID;

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(int)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;
-(void)deleteAllDataFromDB;
-(id)getValueForColumnName:(NSString*)name;
-(NSMutableDictionary*)nextForIndex:(int)matrixIndex;
-(BOOL)hasDataForIndex:(int)matrixIndex;
-(int)rowCountForIndex:(int)matrixIndex;
+ (DBManager *)sharedInstance;

@end
